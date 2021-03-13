library rx.disposables.reference;

import 'package:meta/meta.dart';

import 'disposable.dart';
import 'errors.dart';

/// A [Disposable] holding a disposable value until disposed.
abstract class ReferenceDisposable<T> implements Disposable {
  T? _value;

  ReferenceDisposable(T value) : _value = value;

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
