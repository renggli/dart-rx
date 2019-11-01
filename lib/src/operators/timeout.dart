library rx.operators.timeout;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/settings.dart';

extension TimeoutOperator<T> on Observable<T> {
  /// Completes with a [TimeoutError], if the observable does not complete
  /// within the given duration.
  Observable<T> timeout(Duration duration, {Scheduler scheduler}) =>
      TimeoutObservable<T>(this, scheduler ?? defaultScheduler, duration);
}

class TimeoutObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Scheduler scheduler;
  final Duration duration;

  TimeoutObservable(this.delegate, this.scheduler, this.duration);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = TimeoutSubscriber<T>(observer, scheduler, duration);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TimeoutSubscriber<T> extends Subscriber<T> {
  Subscription subscription;

  TimeoutSubscriber(
      Observer<T> observer, Scheduler scheduler, Duration duration)
      : super(observer) {
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
