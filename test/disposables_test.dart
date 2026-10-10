import 'package:checks/checks.dart';
import 'package:rx/disposables.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

void main() {
  group('errors', () {
    test('DisposedError', () {
      final disposable = ActionDisposable(() {});
      DisposedError.checkNotDisposed(disposable);
      disposable.dispose();
      check(() => DisposedError.checkNotDisposed(disposable))
          .throws<DisposedError>()
          .has((v) => v.toString(), 'toString')
          .equals('DisposedError');
    });

    test('DisposeError', () {
      DisposeError.checkList([]);
      final innerErrors = [ArgumentError(), UnimplementedError()];
      final errors = [Error(), DisposeError(innerErrors)];
      check(() => DisposeError.checkList(errors)).throws<DisposeError>()
        ..has(
          (value) => value.errors,
          'errors',
        ).deepEquals([errors[0], ...innerErrors])
        ..has((v) => v.toString(), 'toString').startsWith('DisposeError');
    });
  });

  group('action', () {
    test('creation', () {
      var disposeCount = 0;
      final disposable = ActionDisposable(() => disposeCount++);
      check(disposable).isDisposed.isFalse();
      check(disposeCount).equals(0);
    });

    test('dispose', () {
      var disposeCount = 0;
      final disposable = ActionDisposable(() => disposeCount++);
      disposable.dispose();
      check(disposable).isDisposed.isTrue();
      check(disposeCount).equals(1);
    });

    test('double dispose', () {
      var disposeCount = 0;
      final disposable = ActionDisposable(() => disposeCount++);
      disposable.dispose();
      disposable.dispose();
      check(disposable).isDisposed.isTrue();
      check(disposeCount).equals(1);
    });

    test('throwing disposable', () {
      final disposable = ActionDisposable(() => throw 'Error');
      check(disposable.dispose).throwsDisposeError();
      check(disposable).isDisposed.isTrue();
    });

    test('double dispose throwing disposable', () {
      final disposable = ActionDisposable(() => throw 'Error');
      check(disposable.dispose).throwsDisposeError();
      disposable.dispose();
    });
  });

  group('collection', () {
    test('list', () {
      final collection = <int>[];
      final disposable = CollectionDisposable.forList(collection, 42);
      check(collection).deepEquals([42]);
      check(disposable).isDisposed.isFalse();
      disposable.dispose();
      check(collection).isEmpty();
      check(disposable).isDisposed.isTrue();
    });

    test('set', () {
      final collection = <int>{};
      final disposable = CollectionDisposable.forSet(collection, 42);
      check(collection).deepEquals({42});
      check(disposable).isDisposed.isFalse();
      disposable.dispose();
      check(collection).isEmpty();
      check(disposable).isDisposed.isTrue();
    });
  });

  group('composite', () {
    test('creation', () {
      final outer = CompositeDisposable();
      check(outer.disposables).isEmpty();
      check(outer).isDisposed.isFalse();
    });

    test('initialization', () {
      final inner = StatefulDisposable();
      final outer = CompositeDisposable([inner, const DisposedDisposable()]);
      check(outer.disposables).deepEquals([inner]);
      check(outer).isDisposed.isFalse();
      check(inner).isDisposed.isFalse();
    });

    test('add', () {
      final outer = CompositeDisposable();
      final inner = StatefulDisposable();
      outer.add(inner);
      check(outer.disposables).deepEquals([inner]);
      check(outer).isDisposed.isFalse();
      check(inner).isDisposed.isFalse();
    });

    test('add inner disposed', () {
      final outer = CompositeDisposable();
      const inner = DisposedDisposable();
      outer.add(inner);
      check(outer.disposables).isEmpty();
      check(outer).isDisposed.isFalse();
    });

    test('add outer disposed', () {
      final outer = CompositeDisposable();
      final inner = StatefulDisposable();
      outer.dispose();
      outer.add(inner);
      check(outer.disposables).isEmpty();
      check(outer).isDisposed.isTrue();
      check(inner).isDisposed.isTrue();
    });

    test('remove inner disposable', () {
      final outer = CompositeDisposable();
      final inner = StatefulDisposable();
      outer.add(inner);
      outer.remove(inner);
      check(outer.disposables).isEmpty();
      check(outer).isDisposed.isFalse();
      check(inner).isDisposed.isTrue();
    });

    test('remove unknown inner disposable', () {
      final outer = CompositeDisposable();
      final inner = StatefulDisposable();
      outer.remove(inner);
      check(outer.disposables).isEmpty();
      check(outer).isDisposed.isFalse();
      check(inner).isDisposed.isFalse();
    });

    test('dispose multiple', () {
      final outer = CompositeDisposable();
      final inner1 = StatefulDisposable();
      final inner2 = StatefulDisposable();
      outer.add(inner1);
      outer.add(inner2);
      outer.dispose();
      check(outer.disposables).isEmpty();
      check(outer).isDisposed.isTrue();
      check(inner1).isDisposed.isTrue();
      check(inner2).isDisposed.isTrue();
    });

    test('dispose throwing', () {
      final outer = CompositeDisposable();
      final inner1 = ActionDisposable(() => throw 'Error');
      final inner2 = StatefulDisposable();
      outer.add(inner1);
      outer.add(inner2);
      check(outer.dispose).throwsDisposeError();
      check(outer.disposables).isEmpty();
      check(outer).isDisposed.isTrue();
      check(inner1).isDisposed.isTrue();
      check(inner2).isDisposed.isTrue();
    });
  });

  group('disposed', () {
    const disposable = DisposedDisposable();
    test('creation', () {
      check(disposable).isDisposed.isTrue();
    });

    test('dispose', () {
      disposable.dispose();
      check(disposable).isDisposed.isTrue();
    });

    test('double dispose', () {
      disposable.dispose();
      disposable.dispose();
      check(disposable).isDisposed.isTrue();
    });
  });

  group('sequential', () {
    test('creation', () {
      final outer = SequentialDisposable();
      check(outer.current).isDisposed.isTrue();
      check(outer).isDisposed.isFalse();
    });

    test('set', () {
      final outer = SequentialDisposable();
      final inner = StatefulDisposable();
      outer.current = inner;
      check(outer.current).equals(inner);
      check(outer.current).isDisposed.isFalse();
      check(outer).isDisposed.isFalse();
    });

    test('set inner disposed', () {
      final outer = SequentialDisposable();
      const inner = DisposedDisposable();
      outer.current = inner;
      check(outer.current).equals(inner);
      check(outer.current).isDisposed.isTrue();
      check(outer).isDisposed.isFalse();
    });

    test('set outer disposed', () {
      final outer = SequentialDisposable();
      final inner = StatefulDisposable();
      outer.dispose();
      outer.current = inner;
      check(outer.current).isDisposed.isTrue();
      check(outer).isDisposed.isTrue();
    });

    test('set replace', () {
      final outer = SequentialDisposable();
      final inner1 = StatefulDisposable();
      final inner2 = StatefulDisposable();
      outer.current = inner1;
      outer.current = inner2;
      check(inner1).isDisposed.isTrue();
      check(inner2).isDisposed.isFalse();
      check(outer.current).equals(inner2);
      check(outer).isDisposed.isFalse();
    });

    test('dispose throwing', () {
      final outer = SequentialDisposable();
      final inner = ActionDisposable(() => throw 'Error');
      outer.current = inner;
      check(outer.dispose).throwsDisposeError();
      check(outer).isDisposed.isTrue();
      check(inner).isDisposed.isTrue();
    });
  });

  group('stateful', () {
    test('creation', () {
      final disposable = StatefulDisposable();
      check(disposable).isDisposed.isFalse();
    });

    test('dispose', () {
      final disposable = StatefulDisposable();
      disposable.dispose();
      check(disposable).isDisposed.isTrue();
    });

    test('double dispose', () {
      final disposable = StatefulDisposable();
      disposable.dispose();
      disposable.dispose();
      check(disposable).isDisposed.isTrue();
    });
  });
}
