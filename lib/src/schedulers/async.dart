library rx.schedulers.async;

import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/action.dart';

class AsyncScheduler extends Scheduler {
  /// Sorted list of immediate actions.
  @protected
  final List<SchedulerAction> immediate = [];

  /// Sorted list of scheduled actions.
  @protected
  final SplayTreeMap<DateTime, List<SchedulerAction>> scheduled =
      SplayTreeMap();

  AsyncScheduler();

  @override
  DateTime get now => DateTime.now();

  @override
  Subscription schedule(Callback callback) {
    final action = SchedulerActionCallback(callback);
    immediate.add(action);
    return action;
  }

  @override
  Subscription scheduleIteration(IterationCallback callback) {
    final action = SchedulerActionCallbackWith((action) {
      if (callback()) {
        immediate.add(action);
      } else {
        action.unsubscribe();
      }
    });
    immediate.add(action);
    return action;
  }

  @override
  Subscription scheduleAbsolute(DateTime dateTime, Callback callback) =>
      _scheduleAt(dateTime, SchedulerActionCallback(callback));

  @override
  Subscription scheduleRelative(Duration duration, Callback callback) =>
      scheduleAbsolute(now.add(duration), callback);

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) =>
      _scheduleAt(now.add(duration), SchedulerActionCallbackWith((action) {
        // TODO(renggli): Re-schedule without drift.
        callback();
        _scheduleAt(now.add(duration), action);
      }));

  SchedulerAction _scheduleAt(DateTime dateTime, SchedulerAction action) {
    final actions = scheduled.putIfAbsent(dateTime, () => []);
    actions.add(action);
    return action;
  }

  void flush() {
    final current = now;
    final pending = List.of(immediate, growable: true);
    while (scheduled.isNotEmpty && !scheduled.firstKey().isAfter(current)) {
      pending.addAll(scheduled.remove(scheduled.firstKey()));
    }
    immediate.clear();
    for (final action in pending) {
      action.run();
    }
  }
}
