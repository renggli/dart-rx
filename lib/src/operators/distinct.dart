library rx.operators.distinct;

import 'dart:collection';

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension DistinctOperator<T> on Observable<T> {
  /// Emits all items emitted by the source that are distinct from previous
  /// items.
  Observable<T> distinct({Predicate2<T, T> equals, Map1<T, int> hashCode}) =>
    DistinctObservable<T>(this, equals, hashCode);
}

class DistinctObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Predicate2<T, T> equalsFunction;
  final Map1<T, int> hashCodeFunction;

  DistinctObservable(this.delegate, this.equalsFunction, this.hashCodeFunction);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(
          DistinctSubscriber<T>(observer, equalsFunction, hashCodeFunction));
}

class DistinctSubscriber<T> extends Subscriber<T> {
  final Set<T> values;

  DistinctSubscriber(Observer<T> observer, Predicate2<T, T> equalsFunction,
      Map1<T, int> hashCodeFunction)
      : values = HashSet(equals: equalsFunction, hashCode: hashCodeFunction),
        super(observer);

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
