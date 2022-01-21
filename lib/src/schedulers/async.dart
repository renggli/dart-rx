import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:more/functional.dart';

import '../disposables/disposable.dart';
import 'action.dart';
import 'scheduler.dart';

/// Asynchronous scheduler that keeps track of pending actions manually.
class AsyncScheduler extends Scheduler {
  AsyncScheduler();

  /// Sorted list of pending actions.
  @protected
  final SplayTreeMap<DateTime, List<SchedulerAction>> scheduled =
      SplayTreeMap();

  /// Returns `true`, if there are actions pending.
  bool get hasPending => scheduled.isNotEmpty;

  /// Performs all the eligible pending actions.
  void flush() {
    final current = now;
    while (scheduled.isNotEmpty && !scheduled.firstKey()!.isAfter(current)) {
      final actions = scheduled.remove(scheduled.firstKey());
      for (final action in actions ?? const <SchedulerAction>[]) {
        action.run();
      }
    }
  }

  @override
  Disposable schedule(Callback0 callback) =>
      _scheduleAt(now, SchedulerActionCallback0(callback));

  @override
  Disposable scheduleIteration(Predicate0 callback) {
    final action = SchedulerActionCallback1((action) {
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
      _scheduleAt(dateTime, SchedulerActionCallback0(callback));

  @override
  Disposable scheduleRelative(Duration duration, Callback0 callback) =>
      scheduleAbsolute(now.add(duration), callback);

  @override
  Disposable schedulePeriodic(
          Duration duration, Callback1<Disposable> callback) =>
      _scheduleAt(now.add(duration), SchedulerActionCallback1((action) {
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
}
