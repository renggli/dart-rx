library rx.operators.distinct;

import 'dart:collection';

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef DistinctEqualsFunction<T> = bool Function(T value1, T value2);
typedef DistinctHashCodeFunction<T> = int Function(T value);

/// Emits all items emitted by the source that are distinct from previous items.
Operator<T, T> distinct<T>(
        {DistinctEqualsFunction<T> equals,
        DistinctHashCodeFunction<T> hashCode}) =>
    (subscriber, source) =>
        source.subscribe(_DistinctSubscriber(subscriber, equals, hashCode));

class _DistinctSubscriber<T> extends Subscriber<T> {
  final Set<T> values;

  _DistinctSubscriber(
      Observer<T> destination,
      DistinctEqualsFunction<T> equalsFunction,
      DistinctHashCodeFunction<T> hashCodeFunction)
      : values = HashSet(equals: equalsFunction, hashCode: hashCodeFunction),
        super(destination);

  @override
  void onNext(T value) {
    if (values.add(value)) {
      doNext(value);
    }
  }
}
