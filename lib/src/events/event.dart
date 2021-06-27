import 'package:meta/meta.dart';
import 'package:more/functional.dart';

import '../core/observer.dart';
import 'complete.dart';
import 'error.dart';
import 'next.dart';

/// Abstract immutable event object of type `T.
@immutable
abstract class Event<T> {
  /// Creates a next event.
  const factory Event.next(T value) = NextEvent<T>;

  /// Creates an error event.
  const factory Event.error(Object object, StackTrace stackTrace) =
      ErrorEvent<T>;

  /// Creates a completion event.
  const factory Event.complete() = CompleteEvent<T>;

  /// Maps the evaluation of the 0-argument callback to an event.
  // ignore: prefer_constructors_over_static_methods
  static Event<R> map0<R>(Map0<R> callback) {
    try {
      return Event<R>.next(callback());
    } catch (error, stackTrace) {
      return Event<R>.error(error, stackTrace);
    }
  }

  /// Maps the evaluation of the 1-argument callback to an event.
  // ignore: prefer_constructors_over_static_methods
  static Event<R> map1<R, T1>(Map1<T1, R> callback, T1 value1) {
    try {
      return Event<R>.next(callback(value1));
    } catch (error, stackTrace) {
      return Event<R>.error(error, stackTrace);
    }
  }

  /// Maps the evaluation of the 2-argument callback to an event.
  // ignore: prefer_constructors_over_static_methods
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

  /// Returns `true`, if this is an event with a [value].
  bool get isNext => false;

  /// Returns `true`, if this is an event with an [error] and an optional
  /// [stackTrace].
  bool get isError => false;

  /// Returns `true`, if this is a completion event.
  bool get isComplete => false;

  /// Returns the value of a [NextEvent], throws otherwise.
  T get value => throw UnsupportedError('$this has no value.');

  /// Returns the error of a [ErrorEvent], throws otherwise.
  Object get error => throw UnsupportedError('$this has no error.');

  /// Returns the optional stack trace of a [ErrorEvent], throws otherwise.
  StackTrace get stackTrace =>
      throw UnsupportedError('$this has no stack trace.');

  /// Performs this event on the [observer].
  void observe(Observer<T> observer);
}
