import 'observable.dart';

/// An error thrown when an error was not handled.
class UnhandledError extends Error {
  UnhandledError(this.error, this.stackTrace);

  final Object error;

  @override
  final StackTrace stackTrace;

  @override
  String toString() => 'UnhandledError{error: $error, stackTrace: $stackTrace}';
}

/// An error thrown when an [Observable] was queried with too few elements.
class TooFewError extends Error {
  TooFewError([this.message = 'Too few elements in sequence.']);

  final String message;

  @override
  String toString() => 'TooFewError{message: $message}';
}

/// An error throw when an [Observable] was queried with too many elements.
class TooManyError extends Error {
  TooManyError([this.message = 'Too many elements in sequence.']);

  final String message;

  @override
  String toString() => 'TooManyError{message: $message}';
}

/// An error thrown when due time elapses.
class TimeoutError extends Error {
  TimeoutError([this.message = 'Timeout has occurred.']);

  final String message;

  @override
  String toString() => 'TimeoutError{message: $message}';
}
