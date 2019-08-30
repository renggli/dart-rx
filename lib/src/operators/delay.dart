library rx.operators.delay;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/settings.dart';

extension DelayOperator<T> on Observable<T> {
  /// Delays the emission of items from the source Observable by a given
  /// timeout.
  Observable<T> delay(Duration delay, {Scheduler scheduler}) =>
     DelayObservable<T>(this, scheduler ?? defaultScheduler, delay);
}

class DelayObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Scheduler scheduler;
  final Duration delay;

  DelayObservable(this.delegate, this.scheduler, this.delay);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(DelaySubscriber<T>(observer, scheduler, delay));
}

class DelaySubscriber<T> extends Subscriber<T> {
  final Scheduler scheduler;
  final Duration delay;

  DelaySubscriber(Observer<T> observer, this.scheduler, this.delay)
      : super(observer);

  @override
  void onNext(T value) =>
      add(scheduler.scheduleRelative(delay, () => doNext(value)));

  @override
  void onComplete() =>
      add(scheduler.scheduleRelative(delay, () => doComplete()));
}
