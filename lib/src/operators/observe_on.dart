import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../schedulers/scheduler.dart';

extension ObserveOnOperator<T> on Observable<T> {
  /// Re-emits all notifications from this [Observable] with a custom scheduler.
  Observable<T> observeOn(Scheduler scheduler, {Duration? delay}) =>
      ObserveOnObservable<T>(this, scheduler, delay);
}

class ObserveOnObservable<T> implements Observable<T> {
  ObserveOnObservable(this.delegate, this.scheduler, this.delay);

  final Observable<T> delegate;
  final Scheduler scheduler;
  final Duration? delay;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = ObserveOnSubscriber<T>(observer, scheduler, delay);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ObserveOnSubscriber<T> extends Subscriber<T> {
  ObserveOnSubscriber(Observer<T> super.observer, this.scheduler, this.delay);

  final Scheduler scheduler;
  final Duration? delay;

  void _schedule(Callback0 callback) => delay == null
      ? scheduler.schedule(callback)
      : scheduler.scheduleRelative(delay!, callback);

  @override
  void onNext(T value) => _schedule(() => doNext(value));

  @override
  void onError(Object error, StackTrace stackTrace) =>
      _schedule(() => doError(error, stackTrace));

  @override
  void onComplete() => _schedule(doComplete);
}
