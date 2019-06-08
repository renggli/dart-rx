library rx.operators.tap;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Perform a side effect for every emission on the source.
Operator<T, T> tap<T>(Observer<T> observer) => _TapOperator<T>(observer);

class _TapOperator<T> implements Operator<T, T> {
  final Observer<T> observer;

  _TapOperator(this.observer);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_TapSubscriber(destination, observer));
}

class _TapSubscriber<T> extends Subscriber<T> {
  final Observer<T> observer;

  _TapSubscriber(Observer<T> destination, this.observer) : super(destination);

  @override
  void onNext(T value) {
    try {
      observer.next(value);
    } catch (error, stackTrace) {
      destination.error(error, stackTrace);
      unsubscribe();
      return;
    }
    destination.next(value);
  }

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    try {
      observer.error(error, stackTrace);
    } catch (error, stackTrace) {
      destination.error(error, stackTrace);
      return;
    }
    destination.error(error, stackTrace);
  }

  @override
  void onComplete() {
    try {
      observer.complete();
    } catch (error, stackTrace) {
      destination.error(error, stackTrace);
      return;
    }
    destination.complete();
  }
}
