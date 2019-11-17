library rx.test.disposables_test;

import 'package:rx/disposables.dart';
import 'package:test/test.dart';

import 'matchers.dart';

void main() {
  group('of', () {
    test('null', () {
      final disposable = Disposable.of(null);
      expect(disposable.isDisposed, isTrue);
    });
    test('callback', () {
      var disposeCount = 0;
      final disposable = Disposable.of(() => disposeCount++);
      expect(disposable.isDisposed, isFalse);
      expect(disposeCount, 0);
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
      expect(disposeCount, 1);
    });
    test('disposable', () {
      final stateful = Disposable.stateful();
      final disposable = Disposable.of(stateful);
      expect(disposable, same(stateful));
    });
    test('unsupported', () {
      expect(() => Disposable.of('mistake'), throwsArgumentError);
    });
  });
  group('empty', () {
    test('creation', () {
      final disposable = Disposable.empty();
      expect(disposable.isDisposed, isTrue);
    });
    test('dispose', () {
      final disposable = Disposable.empty();
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
    });
    test('double dispose', () {
      final disposable = Disposable.empty();
      disposable.dispose();
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
    });
  });
  group('anonymous', () {
    test('creation', () {
      var disposeCount = 0;
      final disposable = Disposable.create(() => disposeCount++);
      expect(disposable.isDisposed, isFalse);
      expect(disposeCount, 0);
    });
    test('dispose', () {
      var disposeCount = 0;
      final disposable = Disposable.create(() => disposeCount++);
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
      expect(disposeCount, 1);
    });
    test('double dispose', () {
      var disposeCount = 0;
      final disposable = Disposable.create(() => disposeCount++);
      disposable.dispose();
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
      expect(disposeCount, 1);
    });
  });
  group('stateful', () {
    test('creation', () {
      final disposable = Disposable.stateful();
      expect(disposable.isDisposed, isFalse);
    });
    test('dispose', () {
      final disposable = Disposable.stateful();
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
    });
    test('double dispose', () {
      final disposable = Disposable.stateful();
      disposable.dispose();
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
    });
  });
  group('composite', () {
    test('creation', () {
      final outer = Disposable.composite();
      expect(outer.subscriptions, isEmpty);
      expect(outer.isDisposed, isFalse);
    });
    test('initialization', () {
      final inner = Disposable.stateful();
      final outer = Disposable.composite([
        inner,
        Disposable.empty(),
      ]);
      expect(outer.subscriptions, [inner]);
      expect(outer.isDisposed, isFalse);
      expect(inner.isDisposed, isFalse);
    });
    test('add', () {
      final outer = Disposable.composite();
      final inner = Disposable.stateful();
      outer.add(inner);
      expect(outer.subscriptions, [inner]);
      expect(outer.isDisposed, isFalse);
      expect(inner.isDisposed, isFalse);
    });
    test('add inner disposed', () {
      final outer = Disposable.composite();
      final inner = Disposable.empty();
      outer.add(inner);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isDisposed, isFalse);
    });
    test('add outer disposed', () {
      final outer = Disposable.composite();
      final inner = Disposable.stateful();
      outer.dispose();
      outer.add(inner);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isDisposed, isTrue);
      expect(inner.isDisposed, isTrue);
    });
    test('remove inner disposable', () {
      final outer = Disposable.composite();
      final inner = Disposable.stateful();
      outer.add(inner);
      outer.remove(inner);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isDisposed, isFalse);
      expect(inner.isDisposed, isTrue);
    });
    test('remove unknown inner disposable', () {
      final outer = Disposable.composite();
      final inner = Disposable.stateful();
      outer.remove(inner);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isDisposed, isFalse);
      expect(inner.isDisposed, isFalse);
    });
    test('dispose multiple', () {
      final outer = Disposable.composite();
      final inner1 = Disposable.stateful();
      final inner2 = Disposable.stateful();
      outer.add(inner1);
      outer.add(inner2);
      outer.dispose();
      expect(outer.subscriptions, isEmpty);
      expect(outer.isDisposed, isTrue);
      expect(inner1.isDisposed, isTrue);
      expect(inner2.isDisposed, isTrue);
    });
    test('dispose throwing', () {
      final outer = Disposable.composite();
      final inner1 = Disposable.create(() => throw 'Error');
      final inner2 = Disposable.stateful();
      outer.add(inner1);
      outer.add(inner2);
      expect(() => outer.dispose(), throwsUnsubscriptionError);
      expect(outer.subscriptions, isEmpty);
      expect(outer.isDisposed, isTrue);
      expect(inner1.isDisposed, isTrue);
      expect(inner2.isDisposed, isTrue);
    });
  });
  group('sequential', () {
    test('creation', () {
      final outer = Disposable.sequential();
      expect(outer.current.isDisposed, isTrue);
      expect(outer.isDisposed, isFalse);
    });
    test('set', () {
      final outer = Disposable.sequential();
      final inner = Disposable.stateful();
      outer.current = inner;
      expect(outer.current, inner);
      expect(outer.current.isDisposed, isFalse);
      expect(outer.isDisposed, isFalse);
    });
    test('set inner disposed', () {
      final outer = Disposable.sequential();
      final inner = Disposable.empty();
      outer.current = inner;
      expect(outer.current, inner);
      expect(outer.current.isDisposed, isTrue);
      expect(outer.isDisposed, isFalse);
    });
    test('set outer disposed', () {
      final outer = Disposable.sequential();
      final inner = Disposable.stateful();
      outer.dispose();
      outer.current = inner;
      expect(outer.current.isDisposed, isTrue);
      expect(outer.isDisposed, isTrue);
    });
    test('set replace', () {
      final outer = Disposable.sequential();
      final inner1 = Disposable.stateful();
      final inner2 = Disposable.stateful();
      outer.current = inner1;
      outer.current = inner2;
      expect(inner1.isDisposed, isTrue);
      expect(inner2.isDisposed, isFalse);
      expect(outer.current, inner2);
      expect(outer.isDisposed, isFalse);
    });
    test('dispose throwing', () {
      final outer = Disposable.sequential();
      final inner = Disposable.create(() => throw 'Error');
      outer.current = inner;
      expect(() => outer.dispose(), throwsUnsubscriptionError);
      expect(outer.isDisposed, isTrue);
      expect(inner.isDisposed, isTrue);
    });
  });
}
