library rx.schedulers.standard;

import 'package:rx/core.dart';
import 'package:rx/src/schedulers/zone.dart';

class ImmediateScheduler extends ZoneScheduler {
  const ImmediateScheduler() : super();

  @override
  Subscription schedule(Callback callback) {
    callback();
    return Subscription.empty();
  }

  @override
  Subscription scheduleIteration(IterationCallback callback) {
    for (; callback();) {}
    return Subscription.empty();
  }
}
