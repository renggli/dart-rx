import 'event.dart';

/// An error throws when an operation receives an unknown [Event] type.
class UnexpectedEventError extends Error {
  final Event event;
  final String message;

  UnexpectedEventError(this.event, [this.message = 'Unexpected event.']);

  @override
  String toString() => 'UnexpectedEventError{event: $event, message: $message}';
}
