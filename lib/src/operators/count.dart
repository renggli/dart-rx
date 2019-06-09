library rx.operators.count;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Counts the number of emissions and emits that number on completion.
Operator<T, int> count<T>() => _CountOperator<T>();

class _CountOperator<T> implements Operator<T, int> {
  _CountOperator();

  @override
  Subscription call(Observable<T> source, Observer<int> destination) =>
      source.subscribe(_CountSubscriber(destination));
}

class _CountSubscriber<T> extends Subscriber<T> {
  int count = 0;

  _CountSubscriber(Observer<int> destination) : super(destination);

  @override
  void onNext(T value) {
    count++;
  }

  @override
  void onComplete() {
    doNext(count);
    doComplete();
  }
}
