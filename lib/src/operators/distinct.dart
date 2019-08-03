library rx.operators.distinct;

import 'dart:collection';

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Emits all items emitted by the source that are distinct from previous items.
OperatorFunction<T, T> distinct<T>(
        {Predicate2<T, T> equals, Map1<T, int> hashCode}) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_DistinctSubscriber<T>(subscriber, equals, hashCode)));

class _DistinctSubscriber<T> extends Subscriber<T> {
  final Set<T> values;

  _DistinctSubscriber(Observer<T> destination, Predicate2<T, T> equalsFunction,
      Map1<T, int> hashCodeFunction)
      : values = HashSet(equals: equalsFunction, hashCode: hashCodeFunction),
        super(destination);

  @override
  void onNext(T value) {
    final addEvent = Event.map1(values.add, value);
    if (addEvent is ErrorEvent) {
      doError(addEvent.error, addEvent.stackTrace);
    } else if (addEvent.value) {
      doNext(value);
    }
  }
}
