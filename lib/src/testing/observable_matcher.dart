library rx.testing.observable_matcher;

import '../core/observable.dart';
import '../core/observer.dart';
import '../operators/map.dart';
import '../operators/materialize.dart';
import '../schedulers/settings.dart';
import 'test_event_sequence.dart';
import 'test_events.dart';
import 'test_scheduler.dart';

class ObservableMatcher<T> {
  final TestEventSequence<T> _expected;

  ObservableMatcher(this._expected);

  bool matches(Object item) {
    if (defaultScheduler is! TestScheduler) {
      throw _ObservableMatcherError('Expected $_expected, '
          'but got $item outside of TestScheduler scope.');
    }

    final TestScheduler scheduler = defaultScheduler;
    final current = scheduler.now;

    int getIndex() =>
        scheduler.now.difference(current).inMilliseconds ~/
        scheduler.stepDuration.inMilliseconds;

    if (item is! Observable<T>) {
      throw _ObservableMatcherError('Expected $_expected, '
          'but got $item that is not of type Observable<$T>.');
    }
    final Observable<T> observable = item;

    final events = <TestEvent<T>>[];
    final subscription = observable
        .materialize()
        .map((event) => TestEvent(getIndex(), event))
        .subscribe(Observer.next(events.add));

    while (scheduler.hasPending && !subscription.isDisposed) {
      scheduler.advance();
    }

    final _actual = TestEventSequence<T>(events, values: _expected.values);
    if (_expected != _actual) {
      throw _ObservableMatcherError('Expected $_expected, '
          'but got $_actual.');
    }

    return true;
  }
}

class _ObservableMatcherError extends Error {
  final String message;
  _ObservableMatcherError(this.message);

  @override
  String toString() => message;
}
