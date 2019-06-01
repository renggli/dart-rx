library rx.schedulers.async;

import 'dart:collection';

import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/action.dart';

class AsyncScheduler extends Scheduler {
  /// Sorted list of immediate actions.
  final List<SchedulerAction> _immediate = [];

  /// Sorted list of scheduled actions.
  final SplayTreeMap<DateTime, List<SchedulerAction>> _scheduled =
      SplayTreeMap();

  AsyncScheduler();

  @override
  DateTime get now => DateTime.now();

  @override
  Subscription schedule(Callback callback) {
    final action = SchedulerAction(callback);
    _immediate.add(action);
    return action;
  }

  @override
  Subscription scheduleIteration(IterationCallback callback) {
    final action = SchedulerAction((action) {
      if (callback()) {
        _immediate.add(action);
      }
    });
    _immediate.add(action);
    return action;
  }

  @override
  Subscription scheduleAbsolute(DateTime dateTime, Callback callback) =>
      _scheduleAt(dateTime, SchedulerAction(callback));

  @override
  Subscription scheduleRelative(Duration duration, Callback callback) =>
      scheduleAbsolute(now.add(duration), callback);

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) =>
      _scheduleAt(now.add(duration), SchedulerAction((action) {
        callback();
        _scheduleAt(now.add(duration), action);
      }));

  SchedulerAction _scheduleAt(DateTime dateTime, SchedulerAction action) {
    final actions = _scheduled.putIfAbsent(dateTime, () => []);
    actions.add(action);
    return action;
  }

  void run() {
    final current = now;
    final pending = List.of(_immediate, growable: true);
    while (_scheduled.isNotEmpty && _scheduled.firstKey().isBefore(current)) {
      pending.addAll(_scheduled.remove(_scheduled.firstKey()));
    }
    _immediate.clear();
    for (final action in pending) {
      action.run();
    }
  }
}
