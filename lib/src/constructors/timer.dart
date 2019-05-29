library rx.constructors.timer;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';

/// An [Observable] that starts emitting after `delay` and emits ever
/// increasing numbers after each `period` thereafter.
Observable<int> timer([Duration delay = Duration.zero, Duration period]) =>
    _TimerObservable(delay, period);

class _TimerObservable with Observable<int> {
  final Duration delay;
  final Duration period;

  const _TimerObservable(this.delay, this.period);

  @override
  Subscription subscribe(Observer<int> observer) =>
      _TimerSubscription(delay, period, observer);
}

class _TimerSubscription implements Subscription {
  final Duration delay;
  final Duration period;
  final Observer<int> observer;
  Subscription subscription;
  int value = 0;

  _TimerSubscription(this.delay, this.period, this.observer) {
    subscription = scheduler.scheduleTimeout(delay, _start);
  }

  @override
  bool get isSubscribed => subscription.isSubscribed;

  @override
  void unsubscribe() => subscription.unsubscribe();

  void _start() {
    _update();
    if (period == null) {
      subscription = const InactiveSubscription();
      observer.complete();
    } else {
      subscription = scheduler.schedulePeriodic(period, _update);
    }
  }

  void _update() {
    observer.next(value++);
  }
}
