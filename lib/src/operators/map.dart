library rx.operators.map;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

typedef MapFunction<T, S> = S Function(T value);

/// Applies a given project function to each value emitted by the source
/// Observable, and emits the resulting values as an Observable.
Operator<T, S> map<T, S>(MapFunction<T, S> mapFunction) =>
    _MapOperator(mapFunction);

class _MapOperator<T, S> implements Operator<T, S> {
  final MapFunction<T, S> mapFunction;

  _MapOperator(this.mapFunction);

  @override
  Subscription call(Observable<T> source, Observer<S> destination) =>
      source.subscribe(_MapSubscriber(destination, mapFunction));
}

class _MapSubscriber<T, S> extends Subscriber<T> {
  final MapFunction<T, S> mapFunction;

  _MapSubscriber(Observer<S> destination, this.mapFunction)
      : super(destination);

  @override
  void onNext(T value) => doNext(mapFunction(value));
}
