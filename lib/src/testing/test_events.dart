library rx.testing.test_events;

import 'package:collection/collection.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';

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
      if (event is NextEvent) {
        return other.event is NextEvent &&
            _equality.equals(event.value, other.event.value);
      } else if (event is ErrorEvent) {
        return other.event is ErrorEvent &&
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
