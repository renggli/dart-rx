library rx.core.events;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/shared/functions.dart';

abstract class Event<T> {
  /// Creates a next event.
  factory Event.next(T value) = NextEvent<T>;

  /// Creates an error event.
  factory Event.error(Object object, [StackTrace stackTrace]) = ErrorEvent<T>;

  /// Creates a completion event.
  factory Event.complete() = CompleteEvent<T>;

  /// Maps the evaluation of the 0-argument callback to an event.
  static Event<R> map0<R>(Map0<R> callback) {
    try {
      return Event<R>.next(callback());
    } catch (error, stackTrace) {
      return Event<R>.error(error, stackTrace);
    }
  }

  /// Maps the evaluation of the 1-argument callback to an event.
  static Event<R> map1<R, T1>(Map1<T1, R> callback, T1 value1) {
    try {
      return Event<R>.next(callback(value1));
    } catch (error, stackTrace) {
      return Event<R>.error(error, stackTrace);
    }
  }

  /// Maps the evaluation of the 2-argument callback to an event.
  static Event<R> map2<R, T1, T2>(
      Map2<T1, T2, R> callback, T1 value1, T2 value2) {
    try {
      return Event<R>.next(callback(value1, value2));
    } catch (error, stackTrace) {
      return Event<R>.error(error, stackTrace);
    }
  }

  /// Default constructor for events.
  const Event();

  /// Returns the value of a [NextEvent], `null` otherwise.
  T get value => null;

  /// Returns the error of a [ErrorEvent], `null` otherwise.
  Object get error => null;

  /// Returns the optional stack trace of a [ErrorEvent], `null` otherwise.
  StackTrace get stackTrace => null;

  /// Performs this event on the [observer].
  void observe(Observer<T> observer);
}

class NextEvent<T> extends Event<T> {
  @override
  final T value;

  const NextEvent(this.value);

  @override
  void observe(Observer<T> observer) => observer.next(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NextEvent && value == other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NextEvent{value: $value}';
}

class ErrorEvent<T> extends Event<T> {
  @override
  final Object error;

  @override
  final StackTrace stackTrace;

  const ErrorEvent(this.error, [this.stackTrace]);

  @override
  void observe(Observer<T> observer) => observer.error(error, stackTrace);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ErrorEvent && error == other.error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'ErrorEvent{error: $error, stackTrace: $stackTrace}';
}

class CompleteEvent<T> extends Event<T> {
  const CompleteEvent();

  @override
  void observe(Observer<T> observer) => observer.complete();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CompleteEvent;

  @override
  int get hashCode => 34822;

  @override
  String toString() => 'CompleteEvent{}';
}
