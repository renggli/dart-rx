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
  Subscription scheduleTimeout(Duration duration, Callback callback) {
    final timestamp = now.add(duration);
    final scheduled = _scheduled.putIfAbsent(timestamp, () => []);
    final action = SchedulerAction(callback);
    scheduled.add(action);
    return action;
  }

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) {
    final action = SchedulerAction((action) {
      final timestamp = now.add(duration);
      final scheduled = _scheduled.putIfAbsent(timestamp, () => []);
      callback();
      scheduled.add(action);
    });
    _immediate.add(action);
    return action;
  }

  void run() {
    final current = now;
    while (_scheduled.isNotEmpty && _scheduled.firstKey().isBefore(current)) {
      _immediate.addAll(_scheduled.remove(_scheduled.firstKey()));
    }
    for (final action in _immediate) {
      action.run();
    }
    _immediate.clear();
  }
}
