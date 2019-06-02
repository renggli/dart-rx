library rx.core.notifications;

import 'package:rx/src/core/observer.dart';

abstract class Notification<T> {
  void observe(Observer<T> observer);
}

class NextNotification<T> implements Notification<T> {
  final T value;

  NextNotification(this.value);

  @override
  void observe(Observer<T> observer) => observer.next(value);

  @override
  bool operator ==(Object other) =>
      other is NextNotification && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NextNotification{value: $value}';
}

class ErrorNotification<T> implements Notification<T> {
  final Object error;
  final StackTrace stackTrace;

  ErrorNotification(this.error, [this.stackTrace]);

  @override
  void observe(Observer<T> observer) => observer.error(error, stackTrace);

  @override
  bool operator ==(Object other) =>
      other is ErrorNotification &&
      error == other.error &&
      stackTrace == other.stackTrace;

  @override
  int get hashCode => error.hashCode ^ stackTrace.hashCode;

  @override
  String toString() =>
      'ErrorNotification{error: $error, stackTrace: $stackTrace}';
}

class CompleteNotification<T> implements Notification<T> {
  CompleteNotification();

  @override
  void observe(Observer<T> observer) => observer.complete();

  @override
  bool operator ==(Object other) => other is CompleteNotification;

  @override
  int get hashCode => 749088;

  @override
  String toString() => 'CompleteNotification{}';
}
