library rx.errors;

class EmptyError extends Error {
  final String message;

  EmptyError([this.message = 'No elements in sequence.']);

  @override
  String toString() => 'EmptyError: $message';
}

class TimeoutError extends Error {
  final String message;

  TimeoutError([this.message = 'Timeout has occurred.']);

  @override
  String toString() => 'TimeoutError: $message';
}
