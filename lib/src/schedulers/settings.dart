library rx.schedulers.settings;

import 'package:rx/schedulers.dart';
import 'package:rx/src/core/scheduler.dart';

/// The default scheduler instance to be used.
Scheduler _defaultScheduler;

/// Returns the default scheduler instance to be used.
Scheduler get defaultScheduler =>
    _defaultScheduler ?? const CurrentZoneScheduler();

/// Replaces the default scheduler instance to be used.
set defaultScheduler(Scheduler scheduler) => _defaultScheduler = scheduler;

/// Tests if the provided scheduler is the default one.
bool isDefaultScheduler(Scheduler scheduler) =>
    identical(defaultScheduler, scheduler);
