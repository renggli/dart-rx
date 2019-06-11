library rx.test.schedulers_test;

import 'package:rx/subscriptions.dart';
import 'package:test/test.dart';

void main() {
  group('anonymous', () {
    test('initial', () {
      var counter = 0;
      final subscription = Subscription.create(() => counter++);
      expect(subscription.isClosed, isFalse);
      expect(counter, 0);
    });
    test('unsubscribe', () {
      var counter = 0;
      final subscription = Subscription.create(() => counter++);
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
      expect(counter, 1);
    });
    test('unsubscribe repeated', () {
      var counter = 0;
      final subscription = Subscription.create(() => counter++);
      subscription.unsubscribe();
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
      expect(counter, 1);
    });
    test('unsubscribe with error', () {
      final subscription = Subscription.create(() => throw Exception());
      expect(() => subscription.unsubscribe(), throwsException);
      expect(subscription.isClosed, isTrue);
    });
  });
  group('empty', () {
    test('initial', () {
      final subscription = Subscription.empty();
      expect(subscription.isClosed, isTrue);
    });
    test('unsubscribe', () {
      final subscription = Subscription.empty();
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
    });
  });
  group('composite', () {
    test('initial', () {
      final subscription = CompositeSubscription();
      expect(subscription.subscriptions, isEmpty);
      expect(subscription.isClosed, isFalse);
    });
    test('add', () {
      final subscription = CompositeSubscription();
      final child = StatefulSubscription();
      subscription.add(child);
      expect(subscription.subscriptions, [child]);
      expect(subscription.isClosed, isFalse);
      expect(child.isClosed, isFalse);
    });
    test('add empty', () {
      final subscription = CompositeSubscription();
      final child = Subscription.empty();
      subscription.add(child);
      expect(subscription.subscriptions, isEmpty);
      expect(subscription.isClosed, isFalse);
      expect(child.isClosed, isTrue);
    });
    test('add closed', () {
      final subscription = CompositeSubscription();
      final child = StatefulSubscription();
      child.unsubscribe();
      subscription.add(child);
      expect(subscription.subscriptions, isEmpty);
      expect(subscription.isClosed, isFalse);
      expect(child.isClosed, isTrue);
    });
    test('remove', () {
      final subscription = CompositeSubscription();
      final child = StatefulSubscription();
      subscription.add(child);
      subscription.remove(child);
      expect(subscription.subscriptions, isEmpty);
      expect(subscription.isClosed, isFalse);
      expect(child.isClosed, isTrue);
    });
    test('remove unknown', () {
      final subscription = CompositeSubscription();
      final child = StatefulSubscription();
      subscription.remove(child);
      expect(subscription.subscriptions, isEmpty);
      expect(subscription.isClosed, isFalse);
      expect(child.isClosed, isFalse);
    });
    test('unsubscribe', () {
      final subscription = CompositeSubscription();
      final child = StatefulSubscription();
      subscription.add(child);
      subscription.unsubscribe();
      expect(subscription.subscriptions, isEmpty);
      expect(subscription.isClosed, isTrue);
      expect(child.isClosed, isTrue);
    });
    test('unsubscribe with error', () {
      final subscription = CompositeSubscription();
      final child1 = Subscription.create(() => throw Exception());
      final child2 = StatefulSubscription();
      subscription.add(child1);
      subscription.add(child2);
      expect(() => subscription.unsubscribe(), throwsException);
      expect(subscription.subscriptions, isEmpty);
      expect(subscription.isClosed, isTrue);
      expect(child1.isClosed, isTrue);
      expect(child2.isClosed, isTrue);
    });
  });
  group('stateful', () {
    test('initial', () {
      final subscription = StatefulSubscription();
      expect(subscription.isClosed, isFalse);
    });
    test('unsubscribe', () {
      final subscription = StatefulSubscription();
      subscription.unsubscribe();
      expect(subscription.isClosed, isTrue);
    });
  });
  group('stream', () {});
  group('timer', () {});
}
