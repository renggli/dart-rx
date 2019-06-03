library rx.schedulers.zone;

import 'dart:async' show Zone;

import 'package:meta/meta.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/action.dart';
import 'package:rx/src/subscriptions/stateful.dart';
import 'package:rx/src/subscriptions/timer.dart';

abstract class ZoneScheduler extends Scheduler {
  const ZoneScheduler();

  @protected
  Zone get zone;

  @override
  DateTime get now => DateTime.now();

  @override
  Subscription schedule(Callback callback) {
    final action = SchedulerAction(callback);
    zone.scheduleMicrotask(action.run);
    return action;
  }

  @override
  Subscription scheduleIteration(IterationCallback callback) {
    final subscription = StatefulSubscription();
    _scheduleIteration(subscription, callback);
    return subscription;
  }

  void _scheduleIteration(Subscription subscription,
      IterationCallback callback) {
    zone.scheduleMicrotask(() =>
        _scheduleIterationExecute(subscription, callback));
  }

  void _scheduleIterationExecute(Subscription subscription,
      IterationCallback callback) {
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
  Subscription scheduleAbsolute(DateTime dateTime, Callback callback) =>
      scheduleRelative(dateTime.difference(now), callback);

  @override
  Subscription scheduleRelative(Duration duration, Callback callback) =>
      TimerSubscription(zone.createTimer(duration, callback));

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) =>
      TimerSubscription(
          zone.createPeriodicTimer(duration, (timer) => callback()));
}

class RootZoneScheduler extends ZoneScheduler {
  const RootZoneScheduler();

  @override
  Zone get zone => Zone.root;
}

class CurrentZoneScheduler extends ZoneScheduler {
  const CurrentZoneScheduler();

  @override
  Zone get zone => Zone.current;
}

