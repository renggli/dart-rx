library rx.disposables.stateful;

import 'disposable.dart';

class StatefulDisposable extends Disposable {
  bool _isDisposed = false;

  StatefulDisposable();

  @override
  void dispose() => _isDisposed = true;

  @override
  bool get isDisposed => _isDisposed;
}
