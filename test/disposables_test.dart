import 'package:rx/disposables.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('errors', () {
    test('DisposedError', () {
      final disposable = ActionDisposable(() {});
      DisposedError.checkNotDisposed(disposable);
      disposable.dispose();
      expect(
          () => DisposedError.checkNotDisposed(disposable),
          throwsA(isA<DisposedError>().having(
              (value) => value.toString(), 'toString', 'DisposedError')));
    });
    test('DisposeError', () {
      DisposeError.checkList([]);
      final innerErrors = [ArgumentError(), UnimplementedError()];
      final errors = [Error(), DisposeError(innerErrors)];
      expect(
          () => DisposeError.checkList(errors),
          throwsA(
            isA<DisposeError>().having((value) => value.errors, 'errors', [
              errors[0],
              ...innerErrors
            ]).having((value) => value.toString(), 'toString()',
                startsWith('DisposeError')),
          ));
    });
  });
  group('action', () {
    test('creation', () {
      var disposeCount = 0;
      final disposable = ActionDisposable(() => disposeCount++);
      expect(disposable.isDisposed, isFalse);
      expect(disposeCount, 0);
    });
    test('dispose', () {
      var disposeCount = 0;
      final disposable = ActionDisposable(() => disposeCount++);
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
      expect(disposeCount, 1);
    });
    test('double dispose', () {
      var disposeCount = 0;
      final disposable = ActionDisposable(() => disposeCount++);
      disposable.dispose();
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
      expect(disposeCount, 1);
    });
    test('throwing disposable', () {
      final disposable = ActionDisposable(() => throw 'Error');
      expect(disposable.dispose, throwsDisposeError);
      expect(disposable.isDisposed, isTrue);
    });
    test('double dispose throwing disposable', () {
      final disposable = ActionDisposable(() => throw 'Error');
      expect(disposable.dispose, throwsDisposeError);
      disposable.dispose();
    });
  });
  group('composite', () {
    test('creation', () {
      final outer = CompositeDisposable();
      expect(outer.disposables, isEmpty);
      expect(outer.isDisposed, isFalse);
    });
    test('initialization', () {
      final inner = StatefulDisposable();
      final outer = CompositeDisposable([
        inner,
        const DisposedDisposable(),
      ]);
      expect(outer.disposables, [inner]);
      expect(outer.isDisposed, isFalse);
      expect(inner.isDisposed, isFalse);
    });
    test('add', () {
      final outer = CompositeDisposable();
      final inner = StatefulDisposable();
      outer.add(inner);
      expect(outer.disposables, [inner]);
      expect(outer.isDisposed, isFalse);
      expect(inner.isDisposed, isFalse);
    });
    test('add inner disposed', () {
      final outer = CompositeDisposable();
      const inner = DisposedDisposable();
      outer.add(inner);
      expect(outer.disposables, isEmpty);
      expect(outer.isDisposed, isFalse);
    });
    test('add outer disposed', () {
      final outer = CompositeDisposable();
      final inner = StatefulDisposable();
      outer.dispose();
      outer.add(inner);
      expect(outer.disposables, isEmpty);
      expect(outer.isDisposed, isTrue);
      expect(inner.isDisposed, isTrue);
    });
    test('remove inner disposable', () {
      final outer = CompositeDisposable();
      final inner = StatefulDisposable();
      outer.add(inner);
      outer.remove(inner);
      expect(outer.disposables, isEmpty);
      expect(outer.isDisposed, isFalse);
      expect(inner.isDisposed, isTrue);
    });
    test('remove unknown inner disposable', () {
      final outer = CompositeDisposable();
      final inner = StatefulDisposable();
      outer.remove(inner);
      expect(outer.disposables, isEmpty);
      expect(outer.isDisposed, isFalse);
      expect(inner.isDisposed, isFalse);
    });
    test('dispose multiple', () {
      final outer = CompositeDisposable();
      final inner1 = StatefulDisposable();
      final inner2 = StatefulDisposable();
      outer.add(inner1);
      outer.add(inner2);
      outer.dispose();
      expect(outer.disposables, isEmpty);
      expect(outer.isDisposed, isTrue);
      expect(inner1.isDisposed, isTrue);
      expect(inner2.isDisposed, isTrue);
    });
    test('dispose throwing', () {
      final outer = CompositeDisposable();
      final inner1 = ActionDisposable(() => throw 'Error');
      final inner2 = StatefulDisposable();
      outer.add(inner1);
      outer.add(inner2);
      expect(outer.dispose, throwsDisposeError);
      expect(outer.disposables, isEmpty);
      expect(outer.isDisposed, isTrue);
      expect(inner1.isDisposed, isTrue);
      expect(inner2.isDisposed, isTrue);
    });
  });
  group('disposed', () {
    const disposable = DisposedDisposable();
    test('creation', () {
      expect(disposable.isDisposed, isTrue);
    });
    test('dispose', () {
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
    });
    test('double dispose', () {
      disposable.dispose();
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
    });
  });
  group('sequential', () {
    test('creation', () {
      final outer = SequentialDisposable();
      expect(outer.current.isDisposed, isTrue);
      expect(outer.isDisposed, isFalse);
    });
    test('set', () {
      final outer = SequentialDisposable();
      final inner = StatefulDisposable();
      outer.current = inner;
      expect(outer.current, inner);
      expect(outer.current.isDisposed, isFalse);
      expect(outer.isDisposed, isFalse);
    });
    test('set inner disposed', () {
      final outer = SequentialDisposable();
      const inner = DisposedDisposable();
      outer.current = inner;
      expect(outer.current, inner);
      expect(outer.current.isDisposed, isTrue);
      expect(outer.isDisposed, isFalse);
    });
    test('set outer disposed', () {
      final outer = SequentialDisposable();
      final inner = StatefulDisposable();
      outer.dispose();
      outer.current = inner;
      expect(outer.current.isDisposed, isTrue);
      expect(outer.isDisposed, isTrue);
    });
    test('set replace', () {
      final outer = SequentialDisposable();
      final inner1 = StatefulDisposable();
      final inner2 = StatefulDisposable();
      outer.current = inner1;
      outer.current = inner2;
      expect(inner1.isDisposed, isTrue);
      expect(inner2.isDisposed, isFalse);
      expect(outer.current, inner2);
      expect(outer.isDisposed, isFalse);
    });
    test('dispose throwing', () {
      final outer = SequentialDisposable();
      final inner = ActionDisposable(() => throw 'Error');
      outer.current = inner;
      expect(outer.dispose, throwsDisposeError);
      expect(outer.isDisposed, isTrue);
      expect(inner.isDisposed, isTrue);
    });
  });
  group('stateful', () {
    test('creation', () {
      final disposable = StatefulDisposable();
      expect(disposable.isDisposed, isFalse);
    });
    test('dispose', () {
      final disposable = StatefulDisposable();
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
    });
    test('double dispose', () {
      final disposable = StatefulDisposable();
      disposable.dispose();
      disposable.dispose();
      expect(disposable.isDisposed, isTrue);
    });
  });
}
