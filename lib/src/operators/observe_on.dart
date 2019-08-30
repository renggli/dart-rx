library rx.operators.observe_on;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension ObserveOnOperator<T> on Observable<T> {
  /// Re-emits all notifications from the source with a custom scheduler.
  Observable<T> observeOn(Scheduler scheduler, {Duration delay}) =>
      ObserveOnObservable<T>(this, scheduler, delay);
}

class ObserveOnObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Scheduler scheduler;
  final Duration delay;

  ObserveOnObservable(this.delegate, this.scheduler, this.delay);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(ObserveOnSubscriber<T>(observer, scheduler, delay));
}

class ObserveOnSubscriber<T> extends Subscriber<T> {
  final Scheduler scheduler;
  final Duration delay;

  ObserveOnSubscriber(Observer<T> observer, this.scheduler, this.delay)
      : super(observer);

  void _schedule(Callback0 callback) => delay == null
      ? scheduler.schedule(callback)
      : scheduler.scheduleRelative(delay, callback);

  @override
  void onNext(T value) => _schedule(() => doNext(value));

  @override
  void onError(Object error, [StackTrace stackTrace]) =>
      _schedule(() => doError(error, stackTrace));

  @override
  void onComplete() => _schedule(doComplete);
}
