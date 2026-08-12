import 'disposable.dart';

/// An already disposed [Disposable].
class DisposedDisposable implements Disposable {
  const new();

  @override
  bool get isDisposed => true;

  @override
  void dispose() {}
}
