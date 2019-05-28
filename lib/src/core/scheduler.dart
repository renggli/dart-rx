library rx.core.scheduler;

import 'dart:async' show Zone;

import 'subscription.dart';

Scheduler scheduler = ZoneScheduler();

typedef Callback = void Function();

abstract class Scheduler {
  DateTime get now;

  Subscription schedule(Callback callback);

  Subscription scheduleTimeout(Duration duration, Callback callback);

  Subscription schedulePeriodic(Duration duration, Callback callback);
}

class ZoneScheduler implements Scheduler {
  final Zone zone;

  ZoneScheduler([Zone zone]) : zone = zone ?? Zone.current;

  @override
  DateTime get now => DateTime.now();

  @override
  Subscription schedule(Callback callback) {
    final subscription = ActiveSubscription();
    zone.scheduleMicrotask(() {
      if (subscription.isSubscribed) {
        callback();
      }
    });
    return subscription;
  }

  @override
  Subscription scheduleTimeout(Duration duration, Callback callback) =>
      TimerSubscription(zone.createTimer(duration, callback));

  @override
  Subscription schedulePeriodic(Duration duration, Callback callback) =>
      TimerSubscription(
          zone.createPeriodicTimer(duration, (timer) => callback()));
}

abstract class SynchronousScheduler extends ZoneScheduler {
  SynchronousScheduler(Zone zone) : super(zone);

  @override
  Subscription schedule(Callback callback) {
    callback();
    return const EmptySubscription();
  }
}
