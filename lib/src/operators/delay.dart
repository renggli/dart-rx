library rx.operators.delay;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/schedulers/settings.dart';
import 'package:rx/src/shared/functions.dart';

/// Delays the emission of items from the source Observable by a given timeout.
Map1<Observable<T>, Observable<T>> delay<T>(Duration delay,
        {Scheduler scheduler}) =>
    (source) => source.lift((source, subscriber) => source.subscribe(
        _DelaySubscriber<T>(subscriber, scheduler ?? defaultScheduler, delay)));

class _DelaySubscriber<T> extends Subscriber<T> {
  final Scheduler scheduler;
  final Duration delay;

  _DelaySubscriber(Observer<T> destination, this.scheduler, this.delay)
      : super(destination);

  @override
  void onNext(T value) =>
      add(scheduler.scheduleRelative(delay, () => doNext(value)));

  @override
  void onComplete() =>
      add(scheduler.scheduleRelative(delay, () => doComplete()));
}
