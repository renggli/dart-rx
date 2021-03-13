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
  String toString() => 'DisposedError{}';
}

/// An error thrown when one or more errors have occurred during the disposal of
/// resources.
class DisposeError extends Error {
  static void checkList(List errors) {
    if (errors.isNotEmpty) {
      throw DisposeError(errors);
    }
  }

  final List errors;

  DisposeError(List errors)
      : errors = errors
            .expand((error) => error is DisposeError ? error.errors : [error])
            .toList(growable: false);

  @override
  String toString() => 'DisposeError{errors: $errors}';
}
