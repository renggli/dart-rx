import '../core/errors.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../disposables/disposed.dart';
import '../schedulers/scheduler.dart';
import '../schedulers/settings.dart';

extension TimeoutOperator<T> on Observable<T> {
  /// Completes with a [TimeoutError], if the observable does not complete
  /// within the given duration.
  Observable<T> timeout(Duration duration, {Scheduler? scheduler}) =>
      TimeoutObservable<T>(this, scheduler ?? defaultScheduler, duration);
}

class TimeoutObservable<T> implements Observable<T> {
  TimeoutObservable(this.delegate, this.scheduler, this.duration);

  final Observable<T> delegate;
  final Scheduler scheduler;
  final Duration duration;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = TimeoutSubscriber<T>(observer, scheduler, duration);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TimeoutSubscriber<T> extends Subscriber<T> {
  TimeoutSubscriber(
      Observer<T> super.observer, Scheduler scheduler, Duration duration) {
    subscription = scheduler.scheduleRelative(duration, onTimeout);
  }

  Disposable subscription = const DisposedDisposable();

  void onTimeout() {
    doError(TimeoutError(), StackTrace.current);
  }

  @override
  void dispose() {
    subscription.dispose();
    super.dispose();
  }
}
