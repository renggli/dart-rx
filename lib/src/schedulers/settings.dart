library rx.schedulers.settings;

import '../core/scheduler.dart';
import '../disposables/disposable.dart';
import 'zone.dart';

/// The default scheduler instance to be used.
Scheduler _defaultScheduler;

/// Returns the default scheduler instance to be used.
Scheduler get defaultScheduler =>
    _defaultScheduler ?? const CurrentZoneScheduler();

/// Sets the default scheduler instance to be used.
set defaultScheduler(Scheduler scheduler) => _defaultScheduler = scheduler;

/// Replaces the default scheduler instance to be used.
Disposable replaceDefaultScheduler(Scheduler scheduler) {
  final originalScheduler = _defaultScheduler;
  _defaultScheduler = scheduler;
  return Disposable.create(() => _defaultScheduler = originalScheduler);
}
