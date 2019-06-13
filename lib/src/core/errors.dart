library rx.core.errors;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/subscription.dart';

/// An error thrown when an [Observable] was queried with too few elements.
class TooFewError extends Error {
  final String message;

  TooFewError([this.message = 'Too few elements in sequence.']);

  @override
  String toString() => 'EmptyError: $message';
}

/// An error throw when an [Observable] was queried with too many elements.
class TooManyError extends Error {
  final String message;

  TooManyError([this.message = 'Too many elements in sequence.']);

  @override
  String toString() => 'TooManyError: $message';
}

/// An error thrown when due time elapses.
class TimeoutError extends Error {
  final String message;

  TimeoutError([this.message = 'Timeout has occurred.']);

  @override
  String toString() => 'TimeoutError: $message';
}

/// An error thrown when an operation has been performed on an
/// unsubscribed subscription.
class UnsubscribedError extends Error {
  static void checkOpen(Subscription subscription) {
    if (subscription.isClosed) {
      throw UnsubscribedError();
    }
  }
}

/// An error thrown when one or more errors have occurred during the
/// `unsubscribe` of a [Subscription].
class UnsubscriptionError extends Error {
  static void checkList(List errors) {
    if (errors.isNotEmpty) {
      throw UnsubscriptionError(errors
          .expand(
              (error) => error is UnsubscriptionError ? error._errors : [error])
          .toList(growable: false));
    }
  }

  final List _errors;

  UnsubscriptionError(this._errors);

  List get errors => _errors;

  @override
  String toString() => 'UnsubscriptionError: $_errors';
}
