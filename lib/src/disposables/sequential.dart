library rx.disposables.serial;

import 'disposable.dart';
import 'disposed.dart';
import 'stateful.dart';

/// A sequence of [Disposable] instances, that can sequentially hold a single
/// [Disposable] and dispose the previous one.
class SequentialDisposable extends StatefulDisposable {
  Disposable _current = const DisposedDisposable();

  SequentialDisposable([Disposable disposable]) {
    if (disposable != null) {
      current = disposable;
    }
  }

  Disposable get current => _current;

  set current(Disposable disposable) {
    ArgumentError.checkNotNull(disposable, 'disposable');
    if (isDisposed) {
      disposable.dispose();
      return;
    }
    final previous = _current;
    if (disposable.isDisposed) {
      _current = const DisposedDisposable();
    } else {
      _current = disposable;
    }
    previous.dispose();
  }

  @override
  void dispose() {
    super.dispose();
    final previous = _current;
    _current = const DisposedDisposable();
    previous.dispose();
  }
}
