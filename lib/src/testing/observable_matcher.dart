library rx.testing.observable_matcher;

import 'package:matcher/matcher.dart';
import 'package:rx/core.dart';
import 'package:rx/operators.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/schedulers/settings.dart';
import 'package:test/test.dart';
import 'package:test_api/test_api.dart';

import 'test_events.dart';
import 'test_scheduler.dart';

class ObservableMatcher<T> extends Matcher {
  final Matcher _expected;

  ObservableMatcher(this._expected);

  @override
  bool matches(Object item, Map matchState) {
    if (defaultScheduler is! TestScheduler) {
      matchState[this] = 'was invoked without a TestScheduler';
      return false;
    }
    final TestScheduler scheduler = defaultScheduler;
    final current = scheduler.now;

    int getIndex() =>
        scheduler.now.difference(current).inMilliseconds ~/
        scheduler.stepDuration.inMilliseconds;

    if (item is! Observable<T>) {
      matchState[this] = 'was not an Observable';
      return false;
    }
    final Observable<T> observable = item;

    final actual = <TestEvent<T>>[];
    final subscription = observable
        .lift(materialize())
        .lift(map((event) => TestEvent(getIndex(), event)))
        .subscribe(Observer.next(actual.add));

    while (!subscription.isClosed) {
      scheduler.advance();
    }

    return _expected.matches(actual, matchState);
  }

  @override
  Description describe(Description description) =>
      description.add('emits ').addDescriptionOf(_expected);

  @override
  Description describeMismatch(Object item, Description mismatchDescription,
      Map matchState, bool verbose) {
    if (matchState[this] is String) {
      return StringDescription(matchState[this]);
    } else {
      return _expected.describeMismatch(
          item, mismatchDescription, matchState, verbose);
    }
  }
}
