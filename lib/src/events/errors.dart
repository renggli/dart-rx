import 'event.dart';

/// An error throws when an operation receives an unknown [Event] type.
class UnexpectedEventError extends Error {
  UnexpectedEventError(this.event, [this.message = 'Unexpected event.']);

  final Event<dynamic> event;

  final String message;

  @override
  String toString() => 'UnexpectedEventError{event: $event, message: $message}';
}
