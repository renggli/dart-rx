import 'package:meta/meta.dart';
import 'package:more/collection.dart';
import 'package:more/ordering.dart';

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

  /// Sequence of [TestEvent] instances.
  final List<TestEvent<T>> events;

  /// Sequence of [Event] instances (unwrapping the test events).
  Iterable<Event<T>> get baseEvents => events.map((value) => value.event);

  /// Optional mapping from marble tokens to objects.
  final BiMap<String, T> values;

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
          break;
        case groupEndMarker:
          if (!withinGroup) {
            throw ArgumentError.value(marbles, 'marbles', 'Invalid grouping.');
          }
          withinGroup = false;
          break;
        case subscribeMarker:
          if (sequence
              .where((element) => element.event is SubscribeEvent)
              .isNotEmpty) {
            throw ArgumentError.value(
                marbles, 'marbles', 'Repeated subscription.');
          }
          sequence.add(TestEvent(index, const SubscribeEvent()));
          break;
        case unsubscribeMarker:
          if (sequence
              .where((element) => element.event is UnsubscribeEvent)
              .isNotEmpty) {
            throw ArgumentError.value(
                marbles, 'marbles', 'Repeated unsubscription.');
          }
          sequence.add(TestEvent(index, const UnsubscribeEvent()));
          break;
        case completeMarker:
          sequence.add(TestEvent(index, Event<T>.complete()));
          break;
        case errorMarker:
          sequence
              .add(TestEvent(index, Event<T>.error(error, StackTrace.current)));
          break;
        default:
          final marble = marbles[i];
          final value = values.containsKey(marble) ? values[marble] : marble;
          sequence.add(TestEvent(index, Event<T>.next(value as T)));
          break;
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

  /// Converts back the event sequence to a marble string.
  String toMarbles() {
    final buffer = StringBuffer();
    final lastEvent = Ordering.natural<num>()
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
          final event = eventAtIndex.event;
          if (event is SubscribeEvent) {
            buffer.write(subscribeMarker);
          } else if (event is UnsubscribeEvent) {
            buffer.write(unsubscribeMarker);
          } else if (event.isComplete) {
            buffer.write(completeMarker);
          } else if (event.isError) {
            buffer.write(errorMarker);
          } else if (event.isNext) {
            final value = event.value;
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
          } else {
            throw ArgumentError.value(event, 'event');
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
    if (identical(this, other)) {
      return true;
    }
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
