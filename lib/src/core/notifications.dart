library rx.core.notifications;

import 'package:more/hash.dart';
import 'package:rx/src/core/observer.dart';

abstract class Notification<T> {
  factory Notification.next(T value) => NextNotification<T>(value);

  factory Notification.error(Object object, [StackTrace stackTrace]) =>
      ErrorNotification<T>(object, stackTrace);

  factory Notification.complete() => CompleteNotification<T>();

  factory Notification.run(T Function() callback) {
    try {
      return NextNotification<T>(callback());
    } catch (error, stackTrace) {
      return ErrorNotification<T>(error, stackTrace);
    }
  }

  const Notification._();

  T get value => null;

  Object get error => null;

  StackTrace get stackTrace => null;

  void observe(Observer<T> observer);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification<T> &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          error == other.error &&
          stackTrace == other.stackTrace);

  @override
  int get hashCode => hash4(runtimeType, value, error, stackTrace);
}

class NextNotification<T> extends Notification<T> {
  @override
  final T value;

  const NextNotification(this.value) : super._();

  @override
  void observe(Observer<T> observer) => observer.next(value);

  @override
  String toString() => 'NextNotification{value: $value}';
}

class ErrorNotification<T> extends Notification<T> {
  @override
  final Object error;

  @override
  final StackTrace stackTrace;

  const ErrorNotification(this.error, [this.stackTrace]) : super._();

  @override
  void observe(Observer<T> observer) => observer.error(error, stackTrace);

  @override
  String toString() =>
      'ErrorNotification{error: $error, stackTrace: $stackTrace}';
}

class CompleteNotification<T> extends Notification<T> {
  const CompleteNotification() : super._();

  @override
  void observe(Observer<T> observer) => observer.complete();

  @override
  String toString() => 'CompleteNotification{}';
}
