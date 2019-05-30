library rx.core.scheduler;

import 'dart:async' show Zone;

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

  /// Schedules a `callback` to be executed after the specified `duration`.
  Subscription scheduleTimeout(Duration duration, Callback callback);

  /// Schedules a `callback` to be executed periodically every `duration`.
  Subscription schedulePeriodic(Duration duration, Callback callback);
}

class DefaultScheduler extends Scheduler {
  const DefaultScheduler();

  @override
  DateTime get now => DateTime.now();

  @override
  Subscription schedule(Callback callback) {
    final subscription = ActiveSubscription();
    Zone.current.scheduleMicrotask(() {
      if (subscription.isSubscribed) {
        callback();
      }
    });
    return subscription;
  }

  @override
  Subscription scheduleIteration(IterationCallback callback) {
    final subscription = ActiveSubscription();
    void runner() {
      if (subscription.isSubscribed) {
        if (callback()) {
          schedule(runner);
        } else {
          subscription.unsubscribe();
        }
      }
    }

    schedule(runner);
    return subscription;
  }

  @override
  Subscription scheduleTimeout(Duration duration, Callback callback) =>
      TimerSubscription(Zone.current.createTimer(duration, callback));

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) =>
      TimerSubscription(
          Zone.current.createPeriodicTimer(duration, (timer) => callback()));
}

class ImmediateScheduler extends DefaultScheduler {
  const ImmediateScheduler() : super();

  @override
  Subscription schedule(Callback callback) {
    callback();
    return const InactiveSubscription();
  }

  @override
  Subscription scheduleIteration(IterationCallback callback) {
    for (; callback(););
    return const InactiveSubscription();
  }
}
