library rx.operators.timeout;

import '../core/errors.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/scheduler.dart';
import '../core/subscriber.dart';
import '../core/subscription.dart';
import '../schedulers/settings.dart';

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
