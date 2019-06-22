library rx.testing.test_events;

import 'package:collection/collection.dart';
import 'package:more/hash.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';

const deepEquality = DeepCollectionEquality();

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
    }
    return other is TestEvent &&
        index == other.index &&
        event.runtimeType == other.event.runtimeType &&
        deepEquality.equals(event.value, other.event.value) &&
        event.error.runtimeType == other.event.error.runtimeType;
  }

  @override
  int get hashCode => hash2(index, event);

  @override
  String toString() => 'TestEvent{index: $index, event: $event}';
}

class SubscribeEvent<T> extends Event<T> {
  const SubscribeEvent();

  @override
  void observe(Observer<T> observer) {}

  @override
  String toString() => 'SubscribeEvent{}';
}

class UnsubscribeEvent<T> extends Event<T> {
  const UnsubscribeEvent();

  @override
  void observe(Observer<T> observer) {}

  @override
  String toString() => 'UnsubscribeEvent{}';
}
