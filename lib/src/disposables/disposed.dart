import 'disposable.dart';

/// An already disposed [Disposable].
class DisposedDisposable implements Disposable {
  const DisposedDisposable();

  @override
  bool get isDisposed => true;

  @override
  void dispose() {}
}
