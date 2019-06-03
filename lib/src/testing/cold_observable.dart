library rx.testing.cold_observable;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/testing/subscription_log.dart';
import 'package:rx/src/testing/test_events.dart';
import 'package:rx/src/testing/test_scheduler.dart';

class ColdObservable<T> with Observable<T>, SubscriptionLog {
  final TestScheduler scheduler;
  final List<TestEvent<T>> events;

  ColdObservable(this.scheduler, this.events);

  @override
  Subscription subscribe(Observer<T> observer) {
    final current = scheduler.now;
    final subscriber = Subscriber<T>(observer);
    for (final event in events) {
      final timestamp = current.add(scheduler.tickDuration * event.index);
      scheduler.scheduleAbsolute(timestamp, () => event.observe(subscriber));
    }
    subscriber.add(logSubscribed());
    return subscriber;
  }
}
