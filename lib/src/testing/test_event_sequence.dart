import 'package:meta/meta.dart';
import 'package:more/collection.dart';
import 'package:more/comparator.dart';

import '../events/event.dart';
import 'test_events.dart';

const nextMarkers = 'abcdefghijklmnopqrstuvwxyz'
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    '0123456789';
const advanceMarker = '-';
const completeMarker = '|';
const errorMarker = '#';
const groupEndMarker = ')';
const groupStartMarker = '(';
const subscribeMarker = '^';
const unsubscribeMarker = '!';

/// Encapsulates a sequence of [TestEvent] instances.
@immutable
class TestEventSequence<T> {
  /// Constructor of a list of events to an event sequence.
  TestEventSequence(this.events, {Map<String, T> values = const {}})
      : values = BiMap.from(values);

  /// Converts a string of marbles to an event sequence.
  factory TestEventSequence.fromString(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    final sequence = <TestEvent<T>>[];
    var index = 0, withinGroup = false;
    for (var i = 0; i < marbles.length; i++) {
      if (marbles[i].trim().isEmpty) {
        continue; // ignore all whitespaces
      }
      switch (marbles[i]) {
        case advanceMarker:
          break;
        case groupStartMarker:
          if (withinGroup) {
            throw ArgumentError.value(marbles, 'marbles', 'Invalid grouping.');
          }
          withinGroup = true;
        case groupEndMarker:
          if (!withinGroup) {
            throw ArgumentError.value(marbles, 'marbles', 'Invalid grouping.');
          }
          withinGroup = false;
        case subscribeMarker:
          if (sequence.whereType<SubscribeEvent<T>>().isNotEmpty) {
            throw ArgumentError.value(
                marbles, 'marbles', 'Repeated subscription.');
          }
          sequence.add(SubscribeEvent(index));
        case unsubscribeMarker:
          if (sequence.whereType<UnsubscribeEvent<T>>().isNotEmpty) {
            throw ArgumentError.value(
                marbles, 'marbles', 'Repeated unsubscription.');
          }
          sequence.add(UnsubscribeEvent(index));
        case completeMarker:
          sequence.add(WrappedEvent<T>(index, Event<T>.complete()));
        case errorMarker:
          sequence.add(WrappedEvent<T>(
              index, Event<T>.error(error, StackTrace.current)));
        default:
          final marble = marbles[i];
          final value = values.containsKey(marble) ? values[marble] : marble;
          sequence.add(WrappedEvent<T>(index, Event<T>.next(value as T)));
      }
      if (!withinGroup) {
        index++;
      }
    }
    if (withinGroup) {
      throw ArgumentError.value(marbles, 'marbles', 'Invalid grouping.');
    }
    return TestEventSequence(sequence, values: values);
  }

  /// Sequence of [TestEvent] instances.
  final List<TestEvent<T>> events;

  /// Sequence of [Event] instances.
  Iterable<Event<T>> get baseEvents =>
      events.whereType<WrappedEvent<T>>().map((value) => value.event);

  /// Optional mapping from marble tokens to objects.
  final BiMap<String, T> values;

  /// Converts back the event sequence to a marble string.
  String toMarbles() {
    final buffer = StringBuffer();
    final lastEvent = naturalComparable<num>
        .onResultOf<TestEvent<T>>((event) => event.index)
        .maxOf(events);
    final lastIndex = lastEvent.index;
    final eventsByIndex = ListMultimap<int, TestEvent<T>>.fromIterables(
        events.map((event) => event.index), events);
    for (var index = 0; index <= lastIndex; index++) {
      final eventsAtIndex = eventsByIndex[index];
      if (eventsAtIndex.isEmpty) {
        buffer.write(advanceMarker);
      } else {
        if (eventsAtIndex.length > 1) {
          buffer.write(groupStartMarker);
        }
        for (final eventAtIndex in eventsAtIndex) {
          switch (eventAtIndex) {
            case WrappedEvent<T>(event: NextEvent<T>(value: final value)):
              if (values.containsValue(value)) {
                buffer.write(values.inverse[value]);
              } else {
                final unusedCharacter = value is String && value.length == 1
                    ? value
                    : nextMarkers
                        .toList()
                        .firstWhere((char) => !values.containsKey(char));
                values[unusedCharacter] = value;
                buffer.write(unusedCharacter);
              }
            case WrappedEvent<T>(event: ErrorEvent<T>()):
              buffer.write(errorMarker);
            case WrappedEvent<T>(event: CompleteEvent<T>()):
              buffer.write(completeMarker);
            case SubscribeEvent<T>():
              buffer.write(subscribeMarker);
            case UnsubscribeEvent<T>():
              buffer.write(unsubscribeMarker);
          }
        }
        if (eventsAtIndex.length > 1) {
          buffer.write(groupEndMarker);
        }
      }
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is TestEventSequence<T> && events.length == other.events.length) {
      for (var i = 0; i < events.length; i++) {
        if (events[i] != other.events[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll(events);

  @override
  String toString() => 'TestEventSequence<$T>{${toMarbles()}}';
}
