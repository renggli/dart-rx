import 'disposable.dart';

/// A stateful [Disposable] that remembers if it has been disposed.
///
/// For example:
///
/// ```dart
/// final stateful = StatefulDisposable();
/// print(stateful.isDisposed); // false
/// stateful.dispose();
/// print(stateful.isDisposed); // true
/// ```
class StatefulDisposable implements Disposable {
  StatefulDisposable();

  bool _isDisposed = false;

  @override
  void dispose() => _isDisposed = true;

  @override
  bool get isDisposed => _isDisposed;
}
