library rx.test.subscriptions_test;

import 'package:rx/core.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:test/test.dart';

import 'matchers.dart';

void main() {
  group('of', () {
    test('null', () {
      final subscription = Subscription.of(null);
      expect(subscription.isClosed, isTrue);
    });
    test('callback', () {
      var unsubscribeCount = 0;
      final subscription = Subscription.of(() => unsubscribeCount++);
      expect(subscription.isClosed, isFalse);
      expect(unsubscribeCount, 0);
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
      expect(unsubscribeCount, 1);
    });
    test('subscription', () {
      final stateful = Subscription.stateful();
      final subscription = Subscription.of(stateful);
      expect(subscription, same(stateful));
    });
    test('unsupported', () {
      expect(() => Subscription.of('mistake'), throwsArgumentError);
    });
  });
  group('empty', () {
    test('creation', () {
      final subscription = Subscription.empty();
      expect(subscription.isClosed, isTrue);
    });
    test('unsubscribe', () {
      final subscription = Subscription.empty();
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
    });
    test('double unsubscribe', () {
      final subscription = Subscription.empty();
      subscription.unsubscribe();
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
    });
  });
  group('anonymous', () {
    test('creation', () {
      var unsubscribeCount = 0;
      final subscription = Subscription.create(() => unsubscribeCount++);
      expect(subscription.isClosed, isFalse);
      expect(unsubscribeCount, 0);
    });
    test('unsubscribe', () {
      var unsubscribeCount = 0;
      final subscription = Subscription.create(() => unsubscribeCount++);
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
      expect(unsubscribeCount, 1);
    });
    test('double unsubscribe', () {
      var unsubscribeCount = 0;
      final subscription = Subscription.create(() => unsubscribeCount++);
      subscription.unsubscribe();
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
      expect(unsubscribeCount, 1);
    });
  });
  group('stateful', () {
    test('creation', () {
      final subscription = Subscription.stateful();
      expect(subscription.isClosed, isFalse);
    });
    test('unsubscribe', () {
      final subscription = Subscription.stateful();
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
    });
    test('double unsubscribe', () {
      final subscription = Subscription.stateful();
      subscription.unsubscribe();
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
    });
  });
  group('composite', () {
    test('creation', () {
      final outer = Subscription.composite();
      expect(outer.subscriptions, isEmpty);
      expect(outer.isClosed, isFalse);
    });
    test('add', () {
      final outer = Subscription.composite();
      final inner = Subscription.stateful();
      outer.add(inner);
      expect(outer.subscriptions, [inner]);
      expect(outer.isClosed, isFalse);
      expect(inner.isClosed, isFalse);
    });
    test('add inner unsubscribed', () {
      final outer = Subscription.composite();
      final inner = Subscription.empty();
      outer.add(inner);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isClosed, isFalse);
    });
    test('add outer unsubscribed', () {
      final outer = Subscription.composite();
      final inner = Subscription.stateful();
      outer.unsubscribe();
      outer.add(inner);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isClosed, isTrue);
      expect(inner.isClosed, isTrue);
    });
    test('remove inner subscription', () {
      final outer = Subscription.composite();
      final inner = Subscription.stateful();
      outer.add(inner);
      outer.remove(inner);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isClosed, isFalse);
      expect(inner.isClosed, isTrue);
    });
    test('remove unknown inner subscription', () {
      final outer = Subscription.composite();
      final inner = Subscription.stateful();
      outer.remove(inner);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isClosed, isFalse);
      expect(inner.isClosed, isFalse);
    });
    test('unsubscribe multiple', () {
      final outer = Subscription.composite();
      final inner1 = Subscription.stateful();
      final inner2 = Subscription.stateful();
      outer.add(inner1);
      outer.add(inner2);
      outer.unsubscribe();
      expect(outer.subscriptions, isEmpty);
      expect(outer.isClosed, isTrue);
      expect(inner1.isClosed, isTrue);
      expect(inner2.isClosed, isTrue);
    });
    test('unsubscribe throwing', () {
      final outer = Subscription.composite();
      final inner1 = Subscription.create(() => throw 'Error');
      final inner2 = Subscription.stateful();
      outer.add(inner1);
      outer.add(inner2);
      expect(() => outer.unsubscribe(), throwsUnsubscriptionError);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isClosed, isTrue);
      expect(inner1.isClosed, isTrue);
      expect(inner2.isClosed, isTrue);
    });
  });
  group('sequential', () {
    test('creation', () {
      final outer = Subscription.sequential();
      expect(outer.current.isClosed, isTrue);
      expect(outer.isClosed, isFalse);
    });
    test('set', () {
      final outer = Subscription.sequential();
      final inner = Subscription.stateful();
      outer.current = inner;
      expect(outer.current, inner);
      expect(outer.current.isClosed, isFalse);
      expect(outer.isClosed, isFalse);
    });
    test('set inner unsubscribed', () {
      final outer = Subscription.sequential();
      final inner = Subscription.empty();
      outer.current = inner;
      expect(outer.current, inner);
      expect(outer.current.isClosed, isTrue);
      expect(outer.isClosed, isFalse);
    });
    test('set outer unsubscribed', () {
      final outer = Subscription.sequential();
      final inner = Subscription.stateful();
      outer.unsubscribe();
      outer.current = inner;
      expect(outer.current.isClosed, isTrue);
      expect(outer.isClosed, isTrue);
    });
    test('set replace', () {
      final outer = Subscription.sequential();
      final inner1 = Subscription.stateful();
      final inner2 = Subscription.stateful();
      outer.current = inner1;
      outer.current = inner2;
      expect(inner1.isClosed, isTrue);
      expect(inner2.isClosed, isFalse);
      expect(outer.current, inner2);
      expect(outer.isClosed, isFalse);
    });
    test('unsubscribe throwing', () {
      final outer = Subscription.sequential();
      final inner = Subscription.create(() => throw 'Error');
      outer.current = inner;
      expect(() => outer.unsubscribe(), throwsUnsubscriptionError);
      expect(outer.isClosed, isTrue);
      expect(inner.isClosed, isTrue);
    });
  });
}
