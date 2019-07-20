library rx.schedulers.immediate;

import 'package:rx/core.dart';

class ImmediateScheduler extends Scheduler {
  const ImmediateScheduler();

  @override
  DateTime get now => DateTime.now();

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
  Subscription scheduleAbsolute(DateTime dateTime, Callback0 callback) =>
      scheduleRelative(now.difference(dateTime), callback);

  @override
  Subscription scheduleRelative(Duration duration, Callback0 callback) {
    _sleep(duration);
    callback();
    return Subscription.empty();
  }

  @override
  Subscription schedulePeriodic(Duration duration, Callback0 callback) {
    for (;;) {
      _sleep(duration);
      callback();
    }
  }

  void _sleep(Duration duration) {
    final target = now.add(duration);
    while (target.isBefore(now)) {}
  }
}
