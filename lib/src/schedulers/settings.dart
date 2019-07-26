library rx.schedulers.settings;

import 'package:rx/schedulers.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';

/// The default scheduler instance to be used.
Scheduler _defaultScheduler;

/// Returns the default scheduler instance to be used.
Scheduler get defaultScheduler =>
    _defaultScheduler ?? const CurrentZoneScheduler();

/// Sets the default scheduler instance to be used.
set defaultScheduler(Scheduler scheduler) => _defaultScheduler = scheduler;

/// Replaces the default scheduler instance to be used.
Subscription replaceDefaultScheduler(Scheduler scheduler) {
  final originalScheduler = _defaultScheduler;
  _defaultScheduler = scheduler;
  return Subscription.create(() => _defaultScheduler = originalScheduler);
}
