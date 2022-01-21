import 'disposable.dart';

/// An error thrown when an operation has been performed on an
/// disposed resource.
class DisposedError extends Error {
  static void checkNotDisposed(Disposable disposable) {
    if (disposable.isDisposed) {
      throw DisposedError();
    }
  }

  @override
  String toString() => 'DisposedError';
}

/// An error thrown when one or more errors have occurred during the disposal of
/// resources.
class DisposeError extends Error {
  DisposeError(List<Object> errors)
      : errors = errors
            .expand((error) => error is DisposeError ? error.errors : [error])
            .toList(growable: false);

  static void checkList(List<Object> errors) {
    if (errors.isNotEmpty) {
      throw DisposeError(errors);
    }
  }

  final List<Object> errors;

  @override
  String toString() => 'DisposeError{errors: $errors}';
}
