import 'dart:async' show Zone;

import 'package:meta/meta.dart';
import 'package:more/functional.dart';

import '../disposables/disposable.dart';
import '../disposables/stateful.dart';
import '../disposables/timer.dart';
import 'action.dart';
import 'scheduler.dart';

/// Abstract asynchronous scheduler that executes actions in a specific zone.
abstract class ZoneScheduler extends Scheduler {
  const ZoneScheduler();

  @protected
  Zone get zone;

  @override
  Disposable schedule(Callback0 callback) {
    final action = SchedulerActionCallback0(callback);
    zone.scheduleMicrotask(action.run);
    return action;
  }

  @override
  Disposable scheduleIteration(Predicate0 callback) {
    final subscription = StatefulDisposable();
    _scheduleIteration(subscription, callback);
    return subscription;
  }

  void _scheduleIteration(Disposable subscription, Predicate0 callback) {
    zone.scheduleMicrotask(
        () => _scheduleIterationExecute(subscription, callback));
  }

  void _scheduleIterationExecute(Disposable subscription, Predicate0 callback) {
    if (subscription.isDisposed) return;
    if (callback()) {
      _scheduleIteration(subscription, callback);
    } else {
      subscription.dispose();
    }
  }

  @override
  Disposable scheduleAbsolute(DateTime dateTime, Callback0 callback) =>
      scheduleRelative(dateTime.difference(now), callback);

  @override
  Disposable scheduleRelative(Duration duration, Callback0 callback) =>
      TimerDisposable(zone.createTimer(duration, callback));

  @override
  Disposable schedulePeriodic(
      Duration duration, Callback1<Disposable> callback) {
    late TimerDisposable subscription;
    return subscription = TimerDisposable(
        zone.createPeriodicTimer(duration, (timer) => callback(subscription)));
  }
}

/// Asynchronous scheduler that executes actions in [Zone.root].
class RootZoneScheduler extends ZoneScheduler {
  const RootZoneScheduler();

  @override
  Zone get zone => Zone.root;
}

/// Asynchronous scheduler that executes actions in [Zone.current].
class CurrentZoneScheduler extends ZoneScheduler {
  const CurrentZoneScheduler();

  @override
  Zone get zone => Zone.current;
}
