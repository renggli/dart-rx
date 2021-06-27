import 'package:more/functional.dart';

import '../disposables/disposable.dart';
import '../disposables/disposed.dart';
import '../disposables/stateful.dart';
import 'scheduler.dart';

/// Synchronous scheduler, that executes actions in the current thread.
class ImmediateScheduler extends Scheduler {
  const ImmediateScheduler();

  @override
  Disposable schedule(Callback0 callback) {
    callback();
    return const DisposedDisposable();
  }

  @override
  Disposable scheduleIteration(Predicate0 callback) {
    while (callback()) {}
    return const DisposedDisposable();
  }

  @override
  Disposable scheduleAbsolute(DateTime dateTime, Callback0 callback) {
    _busyWaitUntil(dateTime);
    callback();
    return const DisposedDisposable();
  }

  @override
  Disposable scheduleRelative(Duration duration, Callback0 callback) =>
      scheduleAbsolute(now.add(duration), callback);

  @override
  Disposable schedulePeriodic(
      Duration duration, Callback1<Disposable> callback) {
    final subscription = StatefulDisposable();
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
