import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../events/event.dart';

const _equality = DeepCollectionEquality();

@immutable
sealed class TestEvent<T> {
  const TestEvent(this.index);

  final int index;
}

class WrappedEvent<T> extends TestEvent<T> {
  const WrappedEvent(super.index, this.event);

  final Event<T> event;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is WrappedEvent && index == other.index) {
      if (event.isNext) {
        return other.event.isNext &&
            _equality.equals(event.value, other.event.value);
      } else if (event.isError) {
        return other.event.isError &&
            event.error.toString() == other.event.error.toString();
      } else {
        return event == other.event;
      }
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(runtimeType, index, event);

  @override
  String toString() => 'WrappedEvent(index: $index, event: $event)';
}

class SubscribeEvent<T> extends TestEvent<T> {
  const SubscribeEvent(super.index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscribeEvent && other.index == index);

  @override
  int get hashCode => Object.hash(runtimeType, index);

  @override
  String toString() => 'SubscribeEvent<$T>(index: $index)';
}

class UnsubscribeEvent<T> extends TestEvent<T> {
  const UnsubscribeEvent(super.index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnsubscribeEvent && other.index == index);

  @override
  int get hashCode => Object.hash(runtimeType, index);

  @override
  String toString() => 'UnsubscribeEvent<$T>(index: $index)';
}
