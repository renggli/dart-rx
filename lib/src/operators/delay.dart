library rx.operators.delay;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/scheduler.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../schedulers/settings.dart';

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
  Disposable subscribe(Observer<T> observer) {
    final subscriber = DelaySubscriber<T>(observer, scheduler, delay);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
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
