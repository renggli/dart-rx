library rx.constructors.timer;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/scheduler.dart';
import '../core/subscription.dart';
import '../schedulers/settings.dart';

/// An [Observable] that starts emitting after `delay` and that emits an ever
/// increasing numbers after each `period` thereafter.
Observable<int> timer(
    {Duration delay = Duration.zero, Duration period, Scheduler scheduler}) {
  ArgumentError.checkNotNull(delay, 'delay');
  return TimerObservable(delay, period, scheduler ?? defaultScheduler);
}

class TimerObservable with Observable<int> {
  final Duration delay;
  final Duration period;
  final Scheduler scheduler;

  const TimerObservable(this.delay, this.period, this.scheduler);

  @override
  Subscription subscribe(Observer<int> observer) {
    final subscription = Subscription.composite();
    subscription.add(Subscription.create(() => observer.complete()));
    subscription.add(scheduler.scheduleRelative(delay, () {
      observer.next(0);
      if (period == null) {
        subscription.unsubscribe();
      } else {
        var counter = 0;
        subscription.add(scheduler.schedulePeriodic(period, (subscription) {
          observer.next(++counter);
        }));
      }
    }));
    return subscription;
  }
}
