library rx.operators.take;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscription.dart';

/// Emits the first [count] values before completing.
Operator<T, T> take<T>([int count = 1]) => _TakeOperator<T>(count);

class _TakeOperator<T> implements Operator<T, T> {
  final int count;

  _TakeOperator(this.count);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_TakeSubscriber(destination, count));
}

class _TakeSubscriber<T> extends Subscriber<T> {
  int count;

  _TakeSubscriber(Observer<T> destination, this.count) : super(destination);

  @override
  void onNext(T value) {
    destination.next(value);
    if (--count <= 0) {
      complete();
    }
  }
}
