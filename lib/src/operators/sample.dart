import '../constructors/timer.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';
import '../schedulers/scheduler.dart';

extension SampleOperator<T> on Observable<T> {
  /// Emits the most recently emitted value from this [Observable] whenever the
  /// [trigger] emits.
  ///
  /// For example:
  ///
  /// ```dart
  /// [1, 2, 3].toObservable()
  ///     .sample(timer(delay: const Duration(seconds: 1)))
  ///     .subscribe(Observer(next: print)); // prints 3
  /// ```
  Observable<T> sample<R>(Observable<R> trigger) =>
      SampleObservable<T, R>(this, trigger);

  /// Samples the source [Observable] at periodic `duration` intervals.
  ///
  /// For example:
  ///
  /// ```dart
  /// [1, 2, 3].toObservable()
  ///     .sampleTime(const Duration(seconds: 1))
  ///     .subscribe(Observer(next: print)); // prints 3
  /// ```
  Observable<T> sampleTime(Duration duration, {Scheduler? scheduler}) =>
      sample<int>(
        timer(delay: duration, period: duration, scheduler: scheduler),
      );
}

class SampleObservable<T, R> implements Observable<T> {
  SampleObservable(this.delegate, this.trigger);

  final Observable<T> delegate;
  final Observable<R> trigger;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = SampleSubscriber<T, R>(observer, trigger);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SampleSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  SampleSubscriber(Observer<T> super.observer, Observable<R> trigger) {
    add(InnerObserver<R, void>(this, trigger, null));
  }

  T? lastValue;
  bool hasLastValue = false;

  @override
  void onNext(T value) {
    lastValue = value;
    hasLastValue = true;
  }

  @override
  void notifyNext(Disposable disposable, void state, R value) => emitValue();

  @override
  void notifyError(
    Disposable disposable,
    void state,
    Object error,
    StackTrace stackTrace,
  ) => doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) => emitValue();

  void emitValue() {
    if (hasLastValue) {
      doNext(lastValue);
      hasLastValue = false;
    }
  }
}
