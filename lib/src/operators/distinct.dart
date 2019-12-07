library rx.operators.distinct;

import 'dart:collection';

import '../core/events.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

extension DistinctOperator<T> on Observable<T> {
  /// Emits all items emitted by this [Observable] that are distinct from
  /// the previous ones.
  Observable<T> distinct({Predicate2<T, T> equals, Map1<T, int> hashCode}) =>
      DistinctObservable<T>(this, equals, hashCode);
}

class DistinctObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Predicate2<T, T> equalsFunction;
  final Map1<T, int> hashCodeFunction;

  DistinctObservable(this.delegate, this.equalsFunction, this.hashCodeFunction);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber =
        DistinctSubscriber<T>(observer, equalsFunction, hashCodeFunction);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
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
