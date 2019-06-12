library rx.operators.filter;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef FilterFunction<T> = bool Function(T value);

/// Filter items emitted by the source Observable by only emitting those that
/// satisfy a specified predicate.
Operator<T, T> filter<T>(FilterFunction filterFunction) =>
    (source, destination) =>
        source.subscribe(_FilterSubscriber(destination, filterFunction));

class _FilterSubscriber<T> extends Subscriber<T> {
  final FilterFunction<T> filterFunction;

  _FilterSubscriber(Observer<T> destination, this.filterFunction)
      : super(destination);

  @override
  void onNext(T value) {
    if (filterFunction(value)) {
      doNext(value);
    }
  }
}
