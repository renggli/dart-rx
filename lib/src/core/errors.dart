library rx.core.errors;

import 'events.dart';
import 'observable.dart';
import 'subscription.dart';

/// An error throws when an operation receives an unknown [Event] type.
class UnexpectedEventError extends Error {
  final Event event;
  final String message;

  UnexpectedEventError(this.event, [this.message = 'Unexpected event.']);

  @override
  String toString() => 'UnexpectedEventError{event: $event, message: $message}';
}

/// An error thrown when an [Observable] was queried with too few elements.
class TooFewError extends Error {
  final String message;

  TooFewError([this.message = 'Too few elements in sequence.']);

  @override
  String toString() => 'TooFewError{message: $message}';
}

/// An error throw when an [Observable] was queried with too many elements.
class TooManyError extends Error {
  final String message;

  TooManyError([this.message = 'Too many elements in sequence.']);

  @override
  String toString() => 'TooManyError{message: $message}';
}

/// An error thrown when due time elapses.
class TimeoutError extends Error {
  final String message;

  TimeoutError([this.message = 'Timeout has occurred.']);

  @override
  String toString() => 'TimeoutError{message: $message}';
}

/// An error thrown when an operation has been performed on an
/// unsubscribed subscription.
class UnsubscribedError extends Error {
  static void checkOpen(Subscription subscription) {
    if (subscription.isClosed) {
      throw UnsubscribedError();
    }
  }

  @override
  String toString() => 'UnsubscribedError{}';
}

/// An error thrown when one or more errors have occurred during the
/// `unsubscribe` of a [Subscription].
class UnsubscriptionError extends Error {
  static void checkList(List errors) {
    if (errors.isNotEmpty) {
      throw UnsubscriptionError(errors);
    }
  }

  final List errors;

  UnsubscriptionError(List<Object> errors)
      : errors = errors
            .expand((error) =>
                error is UnsubscriptionError ? error.errors : [error])
            .toList(growable: false);

  @override
  String toString() => 'UnsubscriptionError{errors: $errors}';
}
