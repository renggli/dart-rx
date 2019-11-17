library rx.schedulers.immediate;

import '../core/scheduler.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

class ImmediateScheduler extends Scheduler {
  const ImmediateScheduler();

  @override
  Disposable schedule(Callback0 callback) {
    callback();
    return Disposable.empty();
  }

  @override
  Disposable scheduleIteration(Predicate0 callback) {
    for (; callback();) {}
    return Disposable.empty();
  }

  @override
  Disposable scheduleAbsolute(DateTime dateTime, Callback0 callback) {
    _busyWaitUntil(dateTime);
    callback();
    return Disposable.empty();
  }

  @override
  Disposable scheduleRelative(Duration duration, Callback0 callback) =>
      scheduleAbsolute(now.add(duration), callback);

  @override
  Disposable schedulePeriodic(
      Duration duration, Callback1<Disposable> callback) {
    final subscription = Disposable.stateful();
    do {
      _busyWaitUntil(now.add(duration));
      callback(subscription);
    } while (!subscription.isDisposed);
    return subscription;
  }

  void _busyWaitUntil(DateTime dateTime) {
    while (!dateTime.isBefore(now)) {
      /* busy wait */
    }
  }
}
