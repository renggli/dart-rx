import '../core/errors.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../disposables/disposed.dart';
import '../schedulers/scheduler.dart';
import '../schedulers/settings.dart';

extension TimeoutOperator<T> on Observable<T> {
  /// totals with a [TimeoutError], if the observable fails to emit a value
  /// in the given time span.
  ///
  /// - `first` specifies the  max duration until the first value must be emitted.
  /// - `between` specifies the max duration between values (or completion).
  /// - `total` specifies the max duration until completion.
  Observable<T> timeout({
    Duration? first,
    Duration? between,
    Duration? total,
    Scheduler? scheduler,
  }) =>
      TimeoutObservable<T>(
          this, first, between, total, scheduler ?? defaultScheduler);
}

class TimeoutObservable<T> implements Observable<T> {
  TimeoutObservable(
      this.delegate, this.first, this.between, this.total, this.scheduler);

  final Observable<T> delegate;
  final Duration? first, between, total;
  final Scheduler scheduler;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber =
        TimeoutSubscriber<T>(observer, first, between, total, scheduler);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TimeoutSubscriber<T> extends Subscriber<T> {
  TimeoutSubscriber(Observer<T> super.observer, this.first, this.between,
      this.total, this.scheduler) {
    if (first != null) {
      nextTimer = scheduler.scheduleRelative(first!, onTimeout);
    }
    if (total != null) {
      totalTimer = scheduler.scheduleRelative(total!, onTimeout);
    }
  }

  final Duration? first, between, total;
  final Scheduler scheduler;

  Disposable nextTimer = const DisposedDisposable();
  Disposable totalTimer = const DisposedDisposable();

  @override
  void onNext(T value) {
    nextTimer.dispose();
    super.onNext(value);
    if (between != null) {
      nextTimer = scheduler.scheduleRelative(between!, onTimeout);
    }
  }

  void onTimeout() {
    doError(TimeoutError(), StackTrace.current);
  }

  @override
  void dispose() {
    nextTimer.dispose();
    totalTimer.dispose();
    super.dispose();
  }
}
