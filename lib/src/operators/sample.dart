library rx.operators.sample;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';

extension SampleOperator<T> on Observable<T> {
  /// Emits the most recently emitted value from this [Observable] whenever the
  /// `trigger` emits.
  Observable<T> sample(Observable trigger) =>
      SampleObservable<T>(this, trigger);
}

class SampleObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Observable trigger;

  SampleObservable(this.delegate, this.trigger);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = SampleSubscriber<T>(observer, trigger);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SampleSubscriber<T> extends Subscriber<T>
    implements InnerEvents<T, void> {
  T lastValue;
  bool hasValue = false;

  SampleSubscriber(Observer<T> observer, Observable trigger) : super(observer) {
    add(InnerObserver(trigger, this));
  }

  @override
  void onNext(T value) {
    lastValue = value;
    hasValue = true;
  }

  @override
  void notifyNext(Disposable subscription, void state, T value) => emitValue();

  @override
  void notifyError(Disposable subscription, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable subscription, void state) => emitValue();

  void emitValue() {
    if (hasValue) {
      doNext(lastValue);
      hasValue = false;
    }
  }
}
