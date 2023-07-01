import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/action.dart';
import '../disposables/composite.dart';
import '../disposables/disposable.dart';
import '../schedulers/scheduler.dart';
import '../schedulers/settings.dart';

/// An [Observable] that starts emitting after `delay` and that emits an ever
/// increasing numbers after each `period` thereafter.
Observable<int> timer(
        {Duration delay = Duration.zero,
        Duration? period,
        Scheduler? scheduler}) =>
    TimerObservable(delay, period, scheduler ?? defaultScheduler);

class TimerObservable implements Observable<int> {
  const TimerObservable(this.delay, this.period, this.scheduler);

  final Duration delay;
  final Duration? period;
  final Scheduler scheduler;

  @override
  Disposable subscribe(Observer<int> observer) {
    final subscription = CompositeDisposable();
    subscription.add(ActionDisposable(observer.complete));
    subscription.add(scheduler.scheduleRelative(delay, () {
      observer.next(0);
      if (period == null) {
        subscription.dispose();
      } else {
        var counter = 0;
        subscription.add(scheduler.schedulePeriodic(period!, (subscription) {
          observer.next(++counter);
        }));
      }
    }));
    return subscription;
  }
}
