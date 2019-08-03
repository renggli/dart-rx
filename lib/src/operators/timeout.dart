library rx.operators.timeout;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/settings.dart';

/// Completes with a [TimeoutError], if the observable does not complete within
/// the given duration.
OperatorFunction<T, T> timeout<T>(Duration duration, {Scheduler scheduler}) =>
    (source) => source.lift((source, subscriber) => source.subscribe(
        _TimeoutSubscriber<T>(
            subscriber, duration, scheduler ?? defaultScheduler)));

class _TimeoutSubscriber<T> extends Subscriber<T> {
  Subscription subscription;

  _TimeoutSubscriber(
      Observer<T> destination, Duration duration, Scheduler scheduler)
      : super(destination) {
    subscription = scheduler.scheduleRelative(duration, onTimeout);
  }

  void onTimeout() {
    doError(TimeoutError());
  }

  @override
  void unsubscribe() {
    subscription.unsubscribe();
    super.unsubscribe();
  }
}
