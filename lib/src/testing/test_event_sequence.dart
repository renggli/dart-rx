library rx.testing.test_event_sequence;

import 'package:collection/collection.dart';
import 'package:more/collection.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/testing/test_events.dart';

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
class TestEventSequence<T> {
  /// Sequence of events.
  final List<TestEvent<T>> events;

  /// Optional mapping from marble tokens to objects.
  final BiMap<String, Object> values;

  // Constructs a sequence of test messages.
  TestEventSequence(this.events, [Map<String, Object> values = const {}])
      : values = BiMap.of(values);

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
          sequence.add(TestEvent(index, SubscribeEvent()));
          break;
        case unsubscribeMarker:
          if (sequence
              .where((element) => element.event is UnsubscribeEvent)
              .isNotEmpty) {
            throw ArgumentError.value(
                marbles, 'marbles', 'Repeated unsubscription.');
          }
          sequence.add(TestEvent(index, UnsubscribeEvent()));
          break;
        case completeMarker:
          sequence.add(TestEvent(index, CompleteEvent()));
          break;
        case errorMarker:
          sequence.add(TestEvent(index, ErrorEvent(error)));
          break;
        default:
          final marble = marbles[i];
          final value = values.containsKey(marble) ? values[marble] : marble;
          sequence.add(TestEvent(index, NextEvent(value)));
          break;
      }
      if (!withinGroup) {
        index++;
      }
    }
    if (withinGroup) {
      throw ArgumentError.value(marbles, 'marbles', 'Invalid grouping.');
    }
    return TestEventSequence(sequence, values);
  }

  /// Converts back the event sequence to a marble string.
  String toMarbles() {
    final buffer = StringBuffer();
    final lastEvent = maxBy(events, (message) => message.index);
    final lastIndex = lastEvent?.index ?? 0;
    final eventsByIndex = groupBy(events, (message) => message.index);
    for (var index = 0; index <= lastIndex; index++) {
      final eventsAtIndex = eventsByIndex[index];
      if (eventsAtIndex == null || eventsAtIndex.isEmpty) {
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
          } else if (event is CompleteEvent) {
            buffer.write(completeMarker);
          } else if (event is ErrorEvent) {
            buffer.write(errorMarker);
          } else if (event is NextEvent) {
            final value = event.value;
            if (values.containsValue(value)) {
              buffer.write(values.inverse[value]);
            } else {
              final unusedCharacter = value is String && value.length == 1
                  ? value
                  : string(nextMarkers)
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
  String toString() => 'TestEventSequence{${toMarbles()}';
}
