library rx.operators.debounce;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/settings.dart';
import 'package:rx/src/shared/functions.dart';

/// Emits a value from the source Observable only after a particular time span
/// has passed without another source emission.
Map1<Observable<T>, Observable<T>> debounce<T>(
        {Duration delay, Scheduler scheduler}) =>
    (source) => source.lift((source, subscriber) => source.subscribe(
        _DebounceSubscriber<T>(
            subscriber, scheduler ?? defaultScheduler, delay)));

class _DebounceSubscriber<T> extends Subscriber<T> {
  final Scheduler scheduler;
  final Duration delay;

  T lastValue;
  bool hasValue = false;
  Subscription subscription;

  _DebounceSubscriber(Observer<T> destination, this.scheduler, this.delay)
      : super(destination);

  @override
  void onNext(T value) {
    reset();
    lastValue = value;
    hasValue = true;
    subscription = scheduler.scheduleRelative(delay, flush);
    add(subscription);
  }

  @override
  void onComplete() {
    flush();
    doComplete();
  }

  void flush() {
    reset();
    if (hasValue) {
      doNext(lastValue);
      lastValue = null;
      hasValue = false;
    }
  }

  void reset() {
    if (subscription != null) {
      subscription.unsubscribe();
      remove(subscription);
      subscription = null;
    }
  }
}
