library rx.schedulers.immediate;

import 'dart:io';

import 'package:rx/core.dart';

class ImmediateScheduler extends Scheduler {
  const ImmediateScheduler();

  @override
  DateTime get now => DateTime.now();

  @override
  Subscription schedule(Callback callback) {
    callback();
    return Subscription.closed();
  }

  @override
  Subscription scheduleIteration(IterationCallback callback) {
    for (; callback();) {}
    return Subscription.closed();
  }

  @override
  Subscription scheduleAbsolute(DateTime dateTime, Callback callback) =>
      scheduleRelative(now.difference(dateTime), callback);

  @override
  Subscription scheduleRelative(Duration duration, Callback callback) {
    sleep(duration);
    callback();
    return Subscription.closed();
  }

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) {
    for (;;) {
      sleep(duration);
      callback();
    }
  }
}
