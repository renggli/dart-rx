library rx.schedulers.zone;

import 'dart:async' show Zone;

import 'package:meta/meta.dart';
import 'package:rx/src/core/functions.dart';
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
  Subscription schedule(Callback0 callback) {
    final action = SchedulerActionCallback(callback);
    zone.scheduleMicrotask(action.run);
    return action;
  }

  @override
  Subscription scheduleIteration(Predicate0 callback) {
    final subscription = StatefulSubscription();
    _scheduleIteration(subscription, callback);
    return subscription;
  }

  void _scheduleIteration(Subscription subscription, Predicate0 callback) {
    zone.scheduleMicrotask(
        () => _scheduleIterationExecute(subscription, callback));
  }

  void _scheduleIterationExecute(
      Subscription subscription, Predicate0 callback) {
    if (subscription.isClosed) {
      return;
    }
    if (callback()) {
      _scheduleIteration(subscription, callback);
    } else {
      subscription.unsubscribe();
    }
  }

  @override
  Subscription scheduleAbsolute(DateTime dateTime, Callback0 callback) =>
      scheduleRelative(dateTime.difference(now), callback);

  @override
  Subscription scheduleRelative(Duration duration, Callback0 callback) =>
      TimerSubscription(zone.createTimer(duration, callback));

  @override
  Subscription schedulePeriodic(Duration duration, Callback0 callback) =>
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
