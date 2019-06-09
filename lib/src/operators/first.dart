library rx.operators.first;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Returns the first element of an observable sequence.
Operator<T, T> first<T>() => _FirstOperator();

class _FirstOperator<T> implements Operator<T, T> {
  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_FirstSubscriber(destination));
}

class _FirstSubscriber<T> extends Subscriber<T> {
  _FirstSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(T value) {
    doNext(value);
    doComplete();
  }

  @override
  void onComplete() {
    doError('Sequence contains no elements');
  }
}
