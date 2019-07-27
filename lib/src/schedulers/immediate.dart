library rx.schedulers.immediate;

import 'package:rx/core.dart';

class ImmediateScheduler extends Scheduler {
  const ImmediateScheduler();

  @override
  Subscription schedule(Callback0 callback) {
    callback();
    return Subscription.empty();
  }

  @override
  Subscription scheduleIteration(Predicate0 callback) {
    for (; callback();) {}
    return Subscription.empty();
  }

  @override
  Subscription scheduleAbsolute(DateTime dateTime, Callback0 callback) {
    _busyWaitUntil(dateTime);
    callback();
    return Subscription.empty();
  }

  @override
  Subscription scheduleRelative(Duration duration, Callback0 callback) =>
      scheduleAbsolute(now.add(duration), callback);

  @override
  Subscription schedulePeriodic(
      Duration duration, Callback1<Subscription> callback) {
    final subscription = Subscription.stateful();
    do {
      _busyWaitUntil(now.add(duration));
      callback(subscription);
    } while (!subscription.isClosed);
    return subscription;
  }

  void _busyWaitUntil(DateTime dateTime) {
    while (!dateTime.isBefore(now)) {
      /* busy wait */
    }
  }
}
