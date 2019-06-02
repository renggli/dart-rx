library rx.testing.test_message;

abstract class TestEvent<T> {
  final int index;

  TestEvent(this.index);

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is ValueEvent && value == other.value;

  @override
  int get hashCode => super.hashCode ^ value.hashCode;

  @override
  String toString() => 'ValueEvent{index: $index, value: $value}';
}

class ErrorEvent<T> extends TestEvent<T> {
  final Object error;

  ErrorEvent(int index, this.error) : super(index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is ErrorEvent && error == other.error;

  @override
  int get hashCode => super.hashCode ^ error.hashCode;

  @override
  String toString() => 'ErrorEvent{index: $index, error: $error}';
}

class CompleteEvent<T> extends TestEvent<T> {
  CompleteEvent(int index) : super(index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || super == other && other is CompleteEvent;

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() => 'CompleteEvent{index: $index}';
}
