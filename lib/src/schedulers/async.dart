library rx.schedulers.async;

import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/action.dart';
import 'package:rx/src/shared/functions.dart';

class AsyncScheduler extends Scheduler {
  /// Sorted list of scheduled actions.
  @protected
  final SplayTreeMap<DateTime, List<SchedulerAction>> scheduled =
      SplayTreeMap();

  AsyncScheduler();

  @override
  Subscription schedule(Callback0 callback) =>
      _scheduleAt(now, SchedulerActionCallback(callback));

  @override
  Subscription scheduleIteration(Predicate0 callback) {
    final action = SchedulerActionCallbackWith((action) {
      if (callback()) {
        _scheduleAt(now, action);
      } else {
        action.unsubscribe();
      }
    });
    _scheduleAt(now, action);
    return action;
  }

  @override
  Subscription scheduleAbsolute(DateTime dateTime, Callback0 callback) =>
      _scheduleAt(dateTime, SchedulerActionCallback(callback));

  @override
  Subscription scheduleRelative(Duration duration, Callback0 callback) =>
      scheduleAbsolute(now.add(duration), callback);

  @override
  Subscription schedulePeriodic(
          Duration duration, Callback1<Subscription> callback) =>
      _scheduleAt(now.add(duration), SchedulerActionCallbackWith((action) {
        callback(action);
        if (!action.isClosed) {
          _scheduleAt(now.add(duration), action);
        }
      }));

  SchedulerAction _scheduleAt(DateTime dateTime, SchedulerAction action) {
    final actions = scheduled.putIfAbsent(dateTime, () => <SchedulerAction>[]);
    actions.add(action);
    return action;
  }

  void flush() {
    final current = now;
    while (scheduled.isNotEmpty && !scheduled.firstKey().isAfter(current)) {
      final actions = scheduled.remove(scheduled.firstKey());
      for (final action in actions) {
        action.run();
      }
    }
  }
}
