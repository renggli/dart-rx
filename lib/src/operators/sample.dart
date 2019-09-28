library rx.operators.sample;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';

extension SampleOperator<T> on Observable<T> {
  /// Emits the most recently emitted value from the source [Observable]
  /// whenever the `trigger` [Observable] emits.
  Observable<T> sample(Observable trigger) =>
      SampleObservable<T>(this, trigger);
}

class SampleObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Observable trigger;

  SampleObservable(this.delegate, this.trigger);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(SampleSubscriber<T>(observer, trigger));
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
  void notifyNext(Subscription subscription, void state, T value) =>
      emitValue();

  @override
  void notifyError(Subscription subscription, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Subscription subscription, void state) => emitValue();

  void emitValue() {
    if (hasValue) {
      doNext(lastValue);
      hasValue = false;
    }
  }
}
