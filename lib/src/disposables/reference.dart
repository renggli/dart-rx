import 'package:meta/meta.dart';

import 'disposable.dart';
import 'errors.dart';

/// A [Disposable] holding a disposable value until disposed.
abstract class ReferenceDisposable<T> implements Disposable {
  ReferenceDisposable(T value) : _value = value;

  T? _value;

  @protected
  void onDispose(T value);

  @override
  void dispose() {
    final value = _value;
    if (value != null) {
      try {
        onDispose(value);
      } catch (error) {
        if (error is DisposeError) {
          rethrow;
        } else {
          throw DisposeError([error]);
        }
      } finally {
        _value = null;
      }
    }
  }

  @override
  bool get isDisposed => _value == null;
}
