import 'package:more/functional.dart';

import '../disposables/disposable.dart';

/// Abstract scheduler implementation.
abstract class Scheduler {
  /// Default constructor of the scheduler.
  const Scheduler();

  /// Returns the current time.
  DateTime get now => DateTime.now();

  /// Schedules a `callback` to be executed.
  Disposable schedule(Callback0 callback);

  /// Schedules a `callback` to be executed while its return value is `true`.
  Disposable scheduleIteration(Predicate0 callback);

  /// Schedules a `callback` to be executed at the specified `dateTime`.
  Disposable scheduleAbsolute(DateTime dateTime, Callback0 callback);

  /// Schedules a `callback` to be executed after the specified `duration`.
  Disposable scheduleRelative(Duration duration, Callback0 callback);

  /// Schedules a `callback` to be executed periodically every `duration`.
  Disposable schedulePeriodic(
      Duration duration, Callback1<Disposable> callback);
}
