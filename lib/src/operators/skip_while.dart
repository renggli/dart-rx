library rx.operators.skip_while;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscription.dart';

typedef SkipWhileConditionFunction<T> = bool Function(T value);

/// Skips over the values while the [conditionFunction] is `true`.
Operator<T, T> skipWhile<T>(SkipWhileConditionFunction conditionFunction) =>
    _SkipWhileOperator<T>(conditionFunction);

class _SkipWhileOperator<T> implements Operator<T, T> {
  final SkipWhileConditionFunction conditionFunction;

  _SkipWhileOperator(this.conditionFunction);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_SkipWhileSubscriber(destination, conditionFunction));
}

class _SkipWhileSubscriber<T> extends Subscriber<T> {
  final SkipWhileConditionFunction conditionFunction;
  bool skipping = true;

  _SkipWhileSubscriber(Observer<T> destination, this.conditionFunction)
      : super(destination);

  @override
  void onNext(T value) {
    if (skipping) {
      if (!conditionFunction(value)) {
        skipping = false;
        destination.next(value);
      }
    } else {
      destination.next(value);
    }
  }
}
