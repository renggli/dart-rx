library rx.testing.test_scheduler;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/schedulers/async.dart';
import 'package:rx/src/schedulers/settings.dart';
import 'package:rx/src/testing/test_event_sequence.dart';
import 'package:test/test.dart';

import 'cold_observable.dart';
import 'hot_observable.dart';
import 'observable_matcher.dart';
import 'test_events.dart';

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
          {Map<String, T> values = const {}, Object error = 'Error'}) =>
      ObservableMatcher<T>(
          TestEventSequence.fromString(marbles, values: values, error: error));

  /// Creates a "cold" [Observable] whose subscription starts when the test
  /// begins.
  Observable<T> cold<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    final sequence =
        TestEventSequence.fromString(marbles, values: values, error: error);
    if (sequence.events.whereType<SubscribeEvent>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Cold observable cannot have subscription marker.');
    }
    if (sequence.events.whereType<UnsubscribeEvent>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Cold observable cannot have unsubscription marker.');
    }
    final observable = ColdObservable<T>(this, sequence);
    coldObservables.add(observable);
    return observable;
  }

  /// Creates a "hot" [Observable] whose subscription starts before the test
  /// begins.
  Observable<T> hot<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    final sequence =
        TestEventSequence.fromString(marbles, values: values, error: error);
    if (sequence.events.whereType<UnsubscribeEvent>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Hot observable cannot have unsubscription marker.');
    }
    final observable = HotObservable<T>(this, sequence);
    hotObservables.add(observable);
    return observable;
  }
}

class TestAction<T> {}
