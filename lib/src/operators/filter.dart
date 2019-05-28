library rx.operators.filter;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

typedef FilterFunction<T> = bool Function(T value);

/// Filter items emitted by the source Observable by only emitting those that
/// satisfy a specified predicate.
Operator<T, T> filter<T>(FilterFunction filterFunction) =>
    _FilterOperator(filterFunction);

class _FilterOperator<T> implements Operator<T, T> {
  final FilterFunction<T> filterFunction;

  _FilterOperator(this.filterFunction);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_FilterSubscriber(destination, filterFunction));
}

class _FilterSubscriber<T> extends Subscriber<T> {
  final FilterFunction<T> filterFunction;

  _FilterSubscriber(Observer<T> destination, this.filterFunction)
      : super(destination);

  @override
  void onNext(T value) {
    if (filterFunction(value)) {
      super.onNext(value);
    }
  }
}
