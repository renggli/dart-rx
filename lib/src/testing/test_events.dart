import 'package:collection/collection.dart';

import '../core/observer.dart';
import '../events/event.dart';

const _equality = DeepCollectionEquality();

class TestEvent<T> extends Event<T> {
  final int index;
  final Event<T> event;

  const TestEvent(this.index, this.event);

  @override
  void observe(Observer<T> observer) => event.observe(observer);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is TestEvent && index == other.index) {
      if (event.isNext) {
        return other.event.isNext &&
            _equality.equals(event.value, other.event.value);
      } else if (event.isError) {
        return other.event.isError &&
            event.error.toString() == other.event.error.toString();
      } else {
        return event == other.event;
      }
    } else {
      return false;
    }
  }

  @override
  int get hashCode => index;

  @override
  String toString() => 'TestEvent{index: $index, event: $event}';
}

class SubscribeEvent<T> extends Event<T> {
  const SubscribeEvent();

  @override
  void observe(Observer<T> observer) {}

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SubscribeEvent;

  @override
  int get hashCode => 36028;

  @override
  String toString() => 'SubscribeEvent{}';
}

class UnsubscribeEvent<T> extends Event<T> {
  const UnsubscribeEvent();

  @override
  void observe(Observer<T> observer) {}

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UnsubscribeEvent;

  @override
  int get hashCode => 84326;

  @override
  String toString() => 'UnsubscribeEvent{}';
}
