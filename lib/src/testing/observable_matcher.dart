library rx.testing.observable_matcher;

import 'package:rx/core.dart';
import 'package:rx/operators.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/schedulers/settings.dart';
import 'package:rx/src/testing/test_event_sequence.dart';

import 'test_events.dart';
import 'test_scheduler.dart';

class ObservableMatcher<T> {
  final TestEventSequence<T> _expected;

  ObservableMatcher(this._expected);

  bool matches(Object item) {
    if (defaultScheduler is! TestScheduler) {
      throw StateError('Expected $item to be evaluated with TestScheduler.');
    }

    final TestScheduler scheduler = defaultScheduler;
    final current = scheduler.now;

    int getIndex() =>
        scheduler.now.difference(current).inMilliseconds ~/
        scheduler.stepDuration.inMilliseconds;

    if (item is! Observable<T>) {
      throw StateError('Expected $item to be an Observable.');
    }
    final Observable<T> observable = item;

    final events = <TestEvent<T>>[];
    final subscription = observable
        .lift(materialize())
        .lift(map((event) => TestEvent(getIndex(), event)))
        .subscribe(Observer.next(events.add));

    while (!subscription.isClosed) {
      scheduler.advance();
    }

    final _actual = TestEventSequence<T>(events, values: _expected.values);
    if (_expected != _actual) {
      throw StateError('Expected $_expected, but got $_actual.');
    }

    return true;
  }
}
