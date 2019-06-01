library rx.schedulers.standard;

import 'dart:async' show Zone;

import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/subscriptions/stateful.dart';
import 'package:rx/src/subscriptions/timer.dart';

class ZoneScheduler extends Scheduler {
  const ZoneScheduler();

  @override
  DateTime get now => DateTime.now();

  @override
  Subscription schedule(Callback callback) {
    final subscription = StatefulSubscription();
    Zone.current.scheduleMicrotask(() => _schedule(subscription, callback));
    return subscription;
  }

  void _schedule(Subscription subscription, Callback callback) {
    if (subscription.isClosed) {
      return;
    }
    callback();
  }

  @override
  Subscription scheduleIteration(IterationCallback callback) {
    final subscription = StatefulSubscription();
    _scheduleIteration(subscription, callback);
    return subscription;
  }

  void _scheduleIteration(
      Subscription subscription, IterationCallback callback) {
    Zone.current.scheduleMicrotask(
        () => _scheduleIterationExecute(subscription, callback));
  }

  void _scheduleIterationExecute(
      Subscription subscription, IterationCallback callback) {
    if (subscription.isClosed) {
      return;
    }
    if (callback()) {
      _scheduleIterationExecute(subscription, callback);
    } else {
      subscription.unsubscribe();
    }
  }

  @override
  Subscription scheduleTimeout(Duration duration, Callback callback) =>
      TimerSubscription(Zone.current.createTimer(duration, callback));

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) =>
      TimerSubscription(
          Zone.current.createPeriodicTimer(duration, (timer) => callback()));
}
