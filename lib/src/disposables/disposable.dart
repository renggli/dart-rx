library rx.core.subscription;

/// A disposable resource.
abstract class Disposable {
  const Disposable();

  /// Disposes the resource.
  void dispose();

  /// Returns true, if this resource has been disposed.
  bool get isDisposed;
}
