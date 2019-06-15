library rx.testing.test_scheduler;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/schedulers/async.dart';
import 'package:rx/src/schedulers/settings.dart';
import 'package:test/test.dart';

import 'cold_observable.dart';
import 'hot_observable.dart';
import 'observable_matcher.dart';
import 'test_events.dart';

const advanceMarker = '-';
const completeMarker = '|';
const errorMarker = '#';
const groupEndMarker = ')';
const groupStartMarker = '(';
const subscribeMarker = '^';
const unsubscribeMarker = '!';

class TestScheduler extends AsyncScheduler {
  DateTime _currentTime;

  final List<Observable> coldObservables = [];
  final List<Observable> hotObservables = [];

  TestScheduler();

  /// Returns the current time.
  @override
  DateTime get now => _currentTime;

  /// Returns the stepping time in this test scenario.
  Duration get stepDuration => const Duration(milliseconds: 1);

  /// Installs a test scheduler.
  void install() {
    var subscription = Subscription.empty();
    setUp(() {
      _currentTime = DateTime.now();
      subscription = replaceDefaultScheduler(this);
    });
    tearDown(() {
      advanceAll();
      coldObservables.clear();
      hotObservables.clear();
      subscription.unsubscribe();
    });
  }

  /// Advances the time to `dateTime`. If omitted advance to the timestamp of
  /// the next scheduled action. If no scheduled action is present, keep the
  /// current timestamp and only flush pending immediate actions.
  void advance([DateTime dateTime]) {
    _currentTime = dateTime ?? scheduled.firstKey() ?? _currentTime;
    flush();
  }

  /// Advances the time as far as possible and execute all existing and new
  /// pending actions on the way.
  void advanceAll() {
    while (scheduled.isNotEmpty) {
      _currentTime = scheduled.firstKey() ?? _currentTime;
      flush();
    }
  }

  /// Creates a matcher for an observable.
  Matcher isObservable<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    final messages = parseEvents<T>(marbles, values: values, error: error);
    return ObservableMatcher<T>(wrapMatcher(messages));
  }

  /// Creates a "cold" [Observable] whose subscription starts when the test
  /// begins.
  Observable<T> cold<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    final events = parseEvents<T>(marbles, values: values, error: error);
    if (events.whereType<SubscribeEvent>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Cold observable cannot have subscription marker.');
    }
    if (events.whereType<UnsubscribeEvent>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Cold observable cannot have unsubscription marker.');
    }
    final observable = ColdObservable<T>(this, events);
    coldObservables.add(observable);
    return observable;
  }

  /// Creates a "hot" [Observable] whose subscription starts before the test
  /// begins.
  Observable<T> hot<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    final events = parseEvents<T>(marbles, values: values, error: error);
    if (events.whereType<UnsubscribeEvent>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Hot observable cannot have unsubscription marker.');
    }
    final observable = HotObservable<T>(this, events);
    hotObservables.add(observable);
    return observable;
  }

  /// Parses a marble string to a list of test events.
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
          if (messages
              .where((element) => element.event is SubscribeEvent)
              .isNotEmpty) {
            throw ArgumentError.value(
                marbles, 'marbles', 'Repeated subscription.');
          }
          messages.add(TestEvent(index, SubscribeEvent()));
          break;
        case unsubscribeMarker:
          if (messages
              .where((element) => element.event is UnsubscribeEvent)
              .isNotEmpty) {
            throw ArgumentError.value(
                marbles, 'marbles', 'Repeated unsubscription.');
          }
          messages.add(TestEvent(index, UnsubscribeEvent()));
          break;
        case completeMarker:
          messages.add(TestEvent(index, CompleteEvent()));
          break;
        case errorMarker:
          messages.add(TestEvent(index, ErrorEvent(error)));
          break;
        default:
          final marble = marbles[i];
          final value = values.containsKey(marble) ? values[marble] : marble;
          messages.add(TestEvent(index, NextEvent(value)));
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
