library rx.testing.cold_observable;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

import 'test_events.dart';
import 'test_observable.dart';
import 'test_scheduler.dart';

class ColdObservable<T> extends TestObservable<T> {
  ColdObservable(TestScheduler scheduler, List<TestEvent<T>> events)
      : super(scheduler, events);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = createSubscriber(observer);
    for (final event in events) {
      final timestamp = scheduler.now.add(scheduler.stepDuration * event.index);
      scheduler.scheduleAbsolute(timestamp, () => event.observe(subscriber));
    }
    return subscriber;
  }
}
