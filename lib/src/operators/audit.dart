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

extension AuditOperator<T> on Observable<T> {
  /// Ignores values from this [Observable] for a duration determined by the
  /// [Observable] returned from `durationSelector`, then emits the most recent
  /// source value, then repeats the process.
  Observable<T> audit<R>(DurationSelector<T, R> durationSelector) =>
      AuditObservable<T, R>(this, durationSelector);

  /// Ignores  values from this [Observable] for the given `duration`, then
  /// emits the most recent source value, then repeats the process.
  Observable<T> auditTime(Duration duration, {Scheduler? scheduler}) =>
      audit<int>(
          constantFunction1(timer(delay: duration, scheduler: scheduler)));
}

class AuditObservable<T, R> implements Observable<T> {
  AuditObservable(this.delegate, this.durationSelector);

  final Observable<T> delegate;
  final DurationSelector<T, R> durationSelector;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = AuditSubscriber<T, R>(observer, durationSelector);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class AuditSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  AuditSubscriber(Observer<T> super.observer, this.durationSelector);

  final DurationSelector<T, R> durationSelector;

  T? lastValue;
  bool hasLastValue = false;
  Disposable? throttled;

  @override
  void onNext(T value) {
    lastValue = value;
    hasLastValue = true;
    if (throttled == null) {
      final durationEvent = Event.map1(durationSelector, value);
      if (durationEvent.isError) {
        doError(durationEvent.error, durationEvent.stackTrace);
      } else {
        add(throttled = InnerObserver(this, durationEvent.value, null));
      }
    }
  }

  @override
  void notifyNext(Disposable disposable, void state, R value) {
    flush();
  }

  @override
  void notifyError(
      Disposable disposable, void state, Object error, StackTrace stackTrace) {
    doError(error, stackTrace);
  }

  @override
  void notifyComplete(Disposable disposable, void state) {
    flush();
  }

  void flush() {
    final value = lastValue;
    final hasValue = hasLastValue;
    final subscription = throttled;
    lastValue = null;
    hasLastValue = false;
    if (subscription != null) {
      remove(subscription);
      throttled = null;
      subscription.dispose();
    }
    if (hasValue) {
      doNext(value);
    }
  }
}
