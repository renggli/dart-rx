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

extension DebounceOperator<T> on Observable<T> {
  /// Emits a value from this [Observable] only after a particular time span
  /// determined by another [Observable] has passed without another emission.
  Observable<T> debounce<R>(DurationSelector<T, R> durationSelector) =>
      DebounceObservable<T, R>(this, durationSelector);

  /// Emits a value from this [Observable] only after a particular time span
  /// has passed without another emission.
  Observable<T> debounceTime(Duration duration, {Scheduler? scheduler}) =>
      debounce<int>(
          constantFunction1(timer(delay: duration, scheduler: scheduler)));
}

class DebounceObservable<T, R> implements Observable<T> {
  DebounceObservable(this.delegate, this.durationSelector);

  final Observable<T> delegate;
  final DurationSelector<T, R> durationSelector;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = DebounceSubscriber<T, R>(observer, durationSelector);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class DebounceSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  DebounceSubscriber(Observer<T> super.observer, this.durationSelector);

  final DurationSelector<T, R> durationSelector;

  T? lastValue;
  bool hasLastValue = false;
  Disposable? debounced;

  @override
  void onNext(T value) {
    final durationEvent = Event.map1(durationSelector, value);
    if (durationEvent.isError) {
      doError(durationEvent.error, durationEvent.stackTrace);
    } else {
      reschedule(durationEvent.value, value);
    }
  }

  @override
  void onComplete() {
    flush();
    doComplete();
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

  void reschedule(Observable<R> duration, T value) {
    reset();
    lastValue = value;
    hasLastValue = true;
    add(debounced = InnerObserver(this, duration, null));
  }

  void reset() {
    lastValue = null;
    hasLastValue = false;
    final subscription = debounced;
    if (subscription != null) {
      debounced = null;
      subscription.dispose();
      remove(subscription);
    }
  }

  void flush() {
    if (hasLastValue) {
      final value = lastValue;
      reset();
      doNext(value);
    }
  }
}
