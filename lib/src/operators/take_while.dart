library rx.operators.take_while;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscription.dart';

typedef TakeWhileConditionFunction<T> = bool Function(T value);

/// Emits values while the [conditionFunction] returns `true`.
Operator<T, T> takeWhile<T>(TakeWhileConditionFunction conditionFunction) =>
    _TakeWhileOperator<T>(conditionFunction);

class _TakeWhileOperator<T> implements Operator<T, T> {
  final TakeWhileConditionFunction conditionFunction;

  _TakeWhileOperator(this.conditionFunction);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_TakeWhileSubscriber(destination, conditionFunction));
}

class _TakeWhileSubscriber<T> extends Subscriber<T> {
  final TakeWhileConditionFunction conditionFunction;

  _TakeWhileSubscriber(Observer<T> destination, this.conditionFunction)
      : super(destination);

  @override
  void onNext(T value) {
    if (conditionFunction(value)) {
      destination.next(value);
    } else {
      destination.complete();
      unsubscribe();
    }
  }
}
