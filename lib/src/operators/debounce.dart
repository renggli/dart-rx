library rx.operators.debounce;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/settings.dart';

extension DebounceOperator<T> on Observable<T> {
  /// Emits a value from the source Observable only after a particular time span
  /// has passed without another source emission.
  Observable<T> debounce({Duration delay, Scheduler scheduler}) =>
      DebounceObservable<T>(this, scheduler ?? defaultScheduler, delay);
}

class DebounceObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Scheduler scheduler;
  final Duration delay;

  DebounceObservable(this.delegate, this.scheduler, this.delay);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(DebounceSubscriber<T>(observer, scheduler, delay));
}

class DebounceSubscriber<T> extends Subscriber<T> {
  final Scheduler scheduler;
  final Duration delay;

  T lastValue;
  bool hasValue = false;
  Subscription subscription;

  DebounceSubscriber(Observer<T> observer, this.scheduler, this.delay)
      : super(observer);

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
