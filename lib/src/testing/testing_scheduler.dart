library rx.testing.test_scheduler;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/testing/cold_observable.dart';
import 'package:rx/src/testing/hot_observable.dart';
import 'package:rx/src/testing/test_message.dart';

const advanceMarker = '-';
const completionMarker = '|';
const errorMarker = '#';
const groupEndMarker = ')';
const groupStartMarker = '(';
const whitespaceMarker = ' ';
const subscriptionMarker = '^';
const unsubscriptionMarker = '!';

class TestScheduler extends Scheduler {
  final List<TestAction> actions = [];

  final List<Observable> coldObservables = [];
  final List<Observable> hotObservables = [];

  TestScheduler();

  final int _millis = 0;

  @override
  DateTime get now => DateTime.fromMillisecondsSinceEpoch(_millis);

  @override
  Subscription schedule(Callback callback) => null;

  @override
  Subscription scheduleIteration(IterationCallback callback) => null;

  @override
  Subscription scheduleAbsolute(DateTime dateTime, Callback callback) => null;

  @override
  Subscription scheduleRelative(Duration duration, Callback callback) => null;

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) => null;

  int createTime(String marbles) {
    final completionIndex = marbles.indexOf(completionMarker);
    if (completionIndex < 0) {
      throw ArgumentError.value(
          marbles, 'Missing completion marker "$completionMarker".');
    }
    return completionIndex;
  }

  Observable<T> createColdObservable<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    if (marbles.contains(subscriptionMarker)) {
      throw ArgumentError.value(
          marbles, 'Unexpected subscription marker "$subscriptionMarker".');
    }
    if (marbles.contains(unsubscriptionMarker)) {
      throw ArgumentError.value(
          marbles, 'Unexpected unsubscription marker "$unsubscriptionMarker".');
    }
    final messages = _parseMarbles<T>(marbles, values, error);
    final observable = ColdObservable<T>(this, messages);
    coldObservables.add(observable);
    return observable;
  }

  Observable<T> createHotObservable<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    if (marbles.contains(unsubscriptionMarker)) {
      throw ArgumentError.value(
          marbles, 'Unexpected unsubscription marker "$unsubscriptionMarker".');
    }
    final messages = _parseMarbles<T>(marbles, values, error);
    final observable = HotObservable<T>(this, messages);
    hotObservables.add(observable);
    return observable;
  }

  List<TestMessage<T>> _parseMarbles<T>(
      String marbles, Map<String, T> values, Object error) {
    final messages = <TestMessage<T>>[];
    var frame = 0, group = -1;
    for (var i = 0; i < marbles.length; i++) {
      Notification<T> notification;
      switch (marbles[i]) {
        case whitespaceMarker:
          break;
        case advanceMarker:
          frame++;
          break;
        case groupStartMarker:
          group = frame;
          frame++;
          break;
        case groupEndMarker:
          group = -1;
          frame++;
          break;
        case errorMarker:
          notification = ErrorNotification<T>(error);
          frame++;
          break;
        case completionMarker:
          notification = CompleteNotification<T>();
          frame++;
          break;
        default:
          final value = values[marbles[i]] ?? marbles[i];
          notification = NextNotification<T>(value);
          frame++;
          break;
      }
      if (notification != null) {
        messages.add(TestMessage(group < 0 ? frame : group, notification));
      }
    }
    return messages;
  }
}

class TestAction<T> {}
