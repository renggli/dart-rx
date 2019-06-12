library rx.operators.skip_while;

import 'package:rx/core.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';

typedef SkipWhileConditionFunction<T> = bool Function(T value);

/// Skips over the values while the [conditionFunction] is `true`.
Operator<T, T> skipWhile<T>(SkipWhileConditionFunction conditionFunction) =>
    (subscriber, source) =>
        source.subscribe(_SkipWhileSubscriber(subscriber, conditionFunction));

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
        doNext(value);
      }
    } else {
      doNext(value);
    }
  }
}
