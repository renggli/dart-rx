library rx.core.scheduler;

import 'package:rx/subscriptions.dart';

import 'subscription.dart';

typedef Callback = void Function();

typedef IterationCallback = bool Function();

abstract class Scheduler {
  const Scheduler();

  /// Returns the current time.
  DateTime get now;

  /// Schedules a `callback` to be executed.
  Subscription schedule(Callback callback);

  /// Schedules a `callback` to while returns value is `true`.
  Subscription scheduleIteration(IterationCallback callback);

  /// Schedules a `callback` to be executed at the specified `dateTime`.
  Subscription scheduleAbsolute(DateTime dateTime, Callback callback);

  /// Schedules a `callback` to be executed after the specified `duration`.
  Subscription scheduleRelative(Duration duration, Callback callback);

  /// Schedules a `callback` to be executed periodically every `duration`.
  Subscription schedulePeriodic(Duration duration, Callback callback);
}
