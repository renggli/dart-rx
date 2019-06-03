library rx.testing.test_scheduler;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/schedulers/async.dart';
import 'package:rx/src/testing/cold_observable.dart';
import 'package:rx/src/testing/hot_observable.dart';
import 'package:rx/src/testing/test_events.dart';

const advanceMarker = '-';
const completeMarker = '|';
const errorMarker = '#';
const groupEndMarker = ')';
const groupStartMarker = '(';
const subscribeMarker = '^';
const unsubscribeMarker = '!';

class TestScheduler extends AsyncScheduler {
  final List<TestAction> actions = [];

  final List<Observable> coldObservables = [];
  final List<Observable> hotObservables = [];

  TestScheduler();

  DateTime currentTime;

  Duration get tickDuration => const Duration(milliseconds: 1);

  @override
  DateTime get now => currentTime;

  int createTime(String marbles) {
    final completionIndex = marbles.indexOf(completeMarker);
    if (completionIndex < 0) {
      throw ArgumentError.value(
          marbles, 'Missing completion marker "$completeMarker".');
    }
    return completionIndex;
  }

  /// Creates a "cold" [Observable] whose subscription starts when the test
  /// begins.
  Observable<T> createColdObservable<T>(String marbles,
      {Map<String, T> values, Object error}) {
    final messages = parseEvents<T>(marbles, values: values, error: error);
    if (messages.whereType<SubscribeEvent>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Cold observable cannot have subscription marker.');
    }
    if (messages.whereType<UnsubscribeEvent>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Cold observable cannot have unsubscription marker.');
    }
    final observable = ColdObservable<T>(this, messages);
    coldObservables.add(observable);
    return observable;
  }

  Observable<T> createHotObservable<T>(String marbles,
      {Map<String, T> values, Object error}) {
    final messages = parseEvents<T>(marbles, values: values, error: error);
    if (messages.whereType<UnsubscribeEvent>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Hot observable cannot have unsubscription marker.');
    }
    final observable = HotObservable<T>(this, messages);
    hotObservables.add(observable);
    return observable;
  }

  static List<TestEvent<T>> parseEvents<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    final messages = <TestEvent<T>>[];
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
          if (messages.whereType<SubscribeEvent>().isNotEmpty) {
            throw ArgumentError.value(
                marbles, 'marbles', 'Repeated subscription.');
          }
          messages.add(SubscribeEvent<T>(index));
          break;
        case unsubscribeMarker:
          if (messages.whereType<UnsubscribeEvent>().isNotEmpty) {
            throw ArgumentError.value(
                marbles, 'marbles', 'Repeated unsubscription.');
          }
          messages.add(UnsubscribeEvent<T>(index));
          break;
        case completeMarker:
          messages.add(CompleteEvent<T>(index));
          break;
        case errorMarker:
          messages.add(ErrorEvent<T>(index, error));
          break;
        default:
          messages.add(ValueEvent<T>(index, values[marbles[i]] ?? marbles[i]));
          break;
      }
      if (!withinGroup) {
        index++;
      }
    }
    if (withinGroup) {
      throw ArgumentError.value(marbles, 'marbles', 'Invalid grouping.');
    }
    return messages;
  }
}

class TestAction<T> {}
