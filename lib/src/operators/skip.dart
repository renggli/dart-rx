library rx.operators.skip;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscription.dart';

/// Skips over the first [count] values before starting to emit.
Operator<T, T> skip<T>([int count = 1]) => _SkipOperator<T>(count);

class _SkipOperator<T> implements Operator<T, T> {
  final int count;

  _SkipOperator(this.count);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_SkipSubscriber(destination, count));
}

class _SkipSubscriber<T> extends Subscriber<T> {
  int count = 0;

  _SkipSubscriber(Observer<T> destination, this.count) : super(destination);

  @override
  void onNext(T value) {
    if (count > 0) {
      count--;
    } else {
      destination.next(value);
    }
  }
}
