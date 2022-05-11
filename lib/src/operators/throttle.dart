import 'package:more/functional.dart';

import '../constructors/timer.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';
import '../observers/inner.dart';
import '../schedulers/scheduler.dart';

typedef DurationSelector<T, R> = Observable<R> Function(T value);

extension ThrottleOperator<T> on Observable<T> {
  /// Emits a value from this [Observable], then ignores values for the duration
  /// until the [Observable] returned by `durationSelector` triggers a value or
  /// completes.
  Observable<T> throttle<R>(DurationSelector<T, R> durationSelector,
          {bool leading = true, bool trailing = true}) =>
      ThrottleObservable<T, R>(this, durationSelector, leading, trailing);

  /// Emits a value from this [Observable], then ignores values for `duration`.
  Observable<T> throttleTime(Duration duration,
          {bool leading = true, bool trailing = true, Scheduler? scheduler}) =>
      throttle<int>(
          constantFunction1(timer(delay: duration, scheduler: scheduler)),
          leading: leading,
          trailing: trailing);
}

class ThrottleObservable<T, R> implements Observable<T> {
  ThrottleObservable(
      this.delegate, this.durationSelector, this.leading, this.trailing);

  final Observable<T> delegate;
  final DurationSelector<T, R> durationSelector;
  final bool leading;
  final bool trailing;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber =
        ThrottleSubscriber<T, R>(observer, durationSelector, leading, trailing);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ThrottleSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  ThrottleSubscriber(Observer<T> super.observer, this.durationSelector,
      this.leading, this.trailing);

  final DurationSelector<T, R> durationSelector;
  final bool leading;
  final bool trailing;

  T? lastValue;
  bool hasLastValue = false;
  Disposable? throttled;

  @override
  void onNext(T value) {
    if (throttled == null) {
      final durationEvent = Event.map1(durationSelector, value);
      if (durationEvent.isError) {
        doError(durationEvent.error, durationEvent.stackTrace);
      } else {
        add(throttled = InnerObserver(this, durationEvent.value, null));
      }
      if (leading) {
        dispatchValue(value);
      } else if (trailing) {
        lastValue = value;
        hasLastValue = true;
      }
    } else {
      if (trailing) {
        lastValue = value;
        hasLastValue = true;
      }
    }
  }

  @override
  void onComplete() {
    if (hasLastValue) {
      dispatchValue(lastValue as T);
    }
    doComplete();
  }

  @override
  void notifyNext(Disposable disposable, void state, R value) {
    dispatchThrottled();
  }

  @override
  void notifyError(
      Disposable disposable, void state, Object error, StackTrace stackTrace) {
    doError(error, stackTrace);
  }

  @override
  void notifyComplete(Disposable disposable, void state) {
    dispatchThrottled();
  }

  void dispatchThrottled() {
    final current = throttled;
    if (current != null) {
      if (hasLastValue && trailing) {
        dispatchValue(lastValue as T);
      }
      current.dispose();
      remove(current);
      throttled = null;
    }
  }

  void dispatchValue(T value) {
    doNext(value);
    lastValue = null;
    hasLastValue = false;
  }
}
