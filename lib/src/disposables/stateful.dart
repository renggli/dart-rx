library rx.disposables.stateful;

import 'disposable.dart';

/// A stateful [Disposable] that remembers if it has been disposed.
class StatefulDisposable implements Disposable {
  bool _isDisposed = false;

  StatefulDisposable();

  @override
  void dispose() => _isDisposed = true;

  @override
  bool get isDisposed => _isDisposed;
}
