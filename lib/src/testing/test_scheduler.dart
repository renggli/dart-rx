import 'package:matcher/matcher.dart';
import 'package:more/temporal.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../disposables/disposed.dart';
import '../operators/map.dart';
import '../operators/materialize.dart';
import '../schedulers/async.dart';
import '../schedulers/settings.dart';
import 'cold_observable.dart';
import 'hot_observable.dart';
import 'test_event_sequence.dart';
import 'test_events.dart';
import 'test_observable.dart';
import 'test_subscriber.dart';

class TestScheduler extends AsyncScheduler {
  TestScheduler();

  DateTime _currentTime = DateTime.now();
  Disposable _subscription = const DisposedDisposable();

  final List<TestObservable<dynamic>> observables = [];
  final List<TestSubscriber<dynamic>> subscribers = [];

  /// Returns the current time.
  @override
  DateTime get now => _currentTime;

  /// Returns the stepping time in this test scenario.
  Duration get stepDuration => const Duration(milliseconds: 1);

  /// Installs the test scheduler, typically done in `setUp` method of test.
  void setUp() {
    if (!_subscription.isDisposed) {
      throw StateError('$this is already set-up.');
    }
    _currentTime = DateTime.now().truncateTo(TimeUnit.day);
    _subscription = replaceDefaultScheduler(this);
  }

  /// Uninstall the test scheduler, typically done in `tearDown` method of test.
  void tearDown() {
    if (_subscription.isDisposed) {
      throw StateError('$this is already tear-down.');
    }
    advanceAll();
    observables.clear();
    subscribers.clear();
    _subscription.dispose();
    _subscription = const DisposedDisposable();
  }

  /// Advances the time to `dateTime`. If omitted advance to the timestamp of
  /// the next scheduled action. If no scheduled action is present, keep the
  /// current timestamp and only flush pending immediate actions.
  void advance([DateTime? dateTime]) {
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
    if (this != defaultScheduler || _subscription.isDisposed) {
      throw StateError('Called outside of the scope of this scheduler.');
    }
    final expected =
        TestEventSequence.fromString(marbles, values: values, error: error);
    return isA<Observable<T>>().having((observable) {
      final start = now;
      final events = <TestEvent<T>>[];
      final subscription = observable
          .materialize()
          .map((event) => WrappedEvent(
              now.difference(start).inMilliseconds ~/
                  stepDuration.inMilliseconds,
              event))
          .subscribe(Observer.next(events.add));
      while (hasPending && !subscription.isDisposed) {
        advance();
      }
      return TestEventSequence<T>(events, values: values);
    }, 'events', expected);
  }

  /// Creates a "cold" [Observable] whose events replay each time it is being
  /// subscribed to.
  Observable<T> cold<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    final sequence =
        TestEventSequence<T>.fromString(marbles, values: values, error: error);
    if (sequence.events.whereType<SubscribeEvent<T>>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Cold observable cannot have subscription marker.');
    }
    if (sequence.events.whereType<UnsubscribeEvent<T>>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Cold observable cannot have un-subscription marker.');
    }
    final observable = ColdObservable<T>(this, sequence);
    observables.add(observable);
    return observable;
  }

  /// Creates a "hot" [Observable] whose event start replaying immediately and
  /// where subscribers all share the same unique run.
  Observable<T> hot<T>(String marbles,
      {Map<String, T> values = const {}, Object error = 'Error'}) {
    final sequence =
        TestEventSequence.fromString(marbles, values: values, error: error);
    if (sequence.events.whereType<UnsubscribeEvent<T>>().isNotEmpty) {
      throw ArgumentError.value(marbles, 'marbles',
          'Hot observable cannot have un-subscription marker.');
    }
    final observable = HotObservable<T>(this, sequence);
    observables.add(observable);
    return observable;
  }
}
