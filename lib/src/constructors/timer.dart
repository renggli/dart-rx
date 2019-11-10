library rx.constructors.timer;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/scheduler.dart';
import '../core/subscription.dart';
import '../schedulers/settings.dart';
import '../subscriptions/sequential.dart';

/// An [Observable] that starts emitting after `delay` and that emits an ever
/// increasing numbers after each `period` thereafter.
Observable<int> timer(
        {Duration delay = Duration.zero,
        Duration period,
        Scheduler scheduler}) =>
    TimerObservable(delay, period, scheduler ?? defaultScheduler);

class TimerObservable with Observable<int> {
  final Duration delay;
  final Duration period;
  final Scheduler scheduler;

  const TimerObservable(this.delay, this.period, this.scheduler);

  @override
  Subscription subscribe(Observer<int> observer) {
    final subscription = SequentialSubscription();
    subscription.current = scheduler.scheduleRelative(delay, () {
      observer.next(0);
      if (period == null) {
        observer.complete();
        subscription.unsubscribe();
      } else {
        var value = 0;
        subscription.current = scheduler.schedulePeriodic(
            period, (subscription) => observer.next(++value));
      }
    });
    return subscription;
  }
}
