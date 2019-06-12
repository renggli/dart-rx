library rx.testing.test_message;

import 'package:collection/collection.dart';
import 'package:rx/src/core/observer.dart';

const equality = MultiEquality([
  ExceptionEquality<Exception>(),
  ExceptionEquality<Error>(),
  DeepCollectionEquality(),
]);

class ExceptionEquality<T> implements Equality<T> {
  const ExceptionEquality();

  @override
  bool equals(T e1, T e2) =>
      e1.runtimeType == e2.runtimeType && e1.toString() == e2.toString();

  @override
  int hash(T e) => e.runtimeType.hashCode ^ e.toString().hashCode;

  @override
  bool isValidKey(Object object) => object is T;
}

abstract class TestEvent<T> {
  final int index;

  TestEvent(this.index);

  void observe(Observer<T> observer) {}

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TestEvent && index == other.index;

  @override
  int get hashCode => index.hashCode;
}

class SubscribeEvent<T> extends TestEvent<T> {
  SubscribeEvent(int index) : super(index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || super == other && other is SubscribeEvent;

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() => 'SubscribeEvent{index: $index}';
}

class UnsubscribeEvent<T> extends TestEvent<T> {
  UnsubscribeEvent(int index) : super(index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || super == other && other is UnsubscribeEvent;

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() => 'UnsubscribeEvent{index: $index}';
}

class ValueEvent<T> extends TestEvent<T> {
  final T value;

  ValueEvent(int index, this.value) : super(index);

  @override
  void observe(Observer<T> observer) => observer.next(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ValueEvent &&
          equality.equals(value, other.value);

  @override
  int get hashCode => super.hashCode ^ equality.hash(value);

  @override
  String toString() => 'ValueEvent{index: $index, value: $value}';
}

class ErrorEvent<T> extends TestEvent<T> {
  final Object error;
  final StackTrace stackTrace;

  ErrorEvent(int index, this.error, [this.stackTrace]) : super(index);

  @override
  void observe(Observer<T> observer) => observer.error(error, stackTrace);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ErrorEvent &&
          equality.equals(error, other.error);

  @override
  int get hashCode => super.hashCode ^ equality.hash(error);

  @override
  String toString() => 'ErrorEvent{index: $index, error: $error}';
}

class CompleteEvent<T> extends TestEvent<T> {
  CompleteEvent(int index) : super(index);

  @override
  void observe(Observer<T> observer) => observer.complete();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || super == other && other is CompleteEvent;

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() => 'CompleteEvent{index: $index}';
}
