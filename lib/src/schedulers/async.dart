library rx.schedulers.async;

import 'dart:collection';

import 'package:meta/meta.dart';

import '../core/scheduler.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';
import 'action.dart';

class AsyncScheduler extends Scheduler {
  /// Sorted list of scheduled actions.
  @protected
  final SplayTreeMap<DateTime, List<SchedulerAction>> scheduled =
      SplayTreeMap();

  AsyncScheduler();

  bool get hasPending => scheduled.isNotEmpty;

  @override
  Disposable schedule(Callback0 callback) =>
      _scheduleAt(now, SchedulerActionCallback(callback));

  @override
  Disposable scheduleIteration(Predicate0 callback) {
    final action = SchedulerActionCallbackWith((action) {
      if (callback()) {
        _scheduleAt(now, action);
      } else {
        action.dispose();
      }
    });
    _scheduleAt(now, action);
    return action;
  }

  @override
  Disposable scheduleAbsolute(DateTime dateTime, Callback0 callback) =>
      _scheduleAt(dateTime, SchedulerActionCallback(callback));

  @override
  Disposable scheduleRelative(Duration duration, Callback0 callback) =>
      scheduleAbsolute(now.add(duration), callback);

  @override
  Disposable schedulePeriodic(
          Duration duration, Callback1<Disposable> callback) =>
      _scheduleAt(now.add(duration), SchedulerActionCallbackWith((action) {
        callback(action);
        if (!action.isDisposed) {
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
