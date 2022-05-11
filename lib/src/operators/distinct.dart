import 'dart:collection';

import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension DistinctOperator<T> on Observable<T> {
  /// Emits all items emitted by this [Observable] that are distinct from
  /// the previous ones.
  Observable<T> distinct({Predicate2<T, T>? equals, Map1<T, int>? hashCode}) =>
      DistinctObservable<T>(this, equals, hashCode);
}

class DistinctObservable<T> implements Observable<T> {
  DistinctObservable(this.delegate, this.equalsFunction, this.hashCodeFunction);

  final Observable<T> delegate;
  final Predicate2<T, T>? equalsFunction;
  final Map1<T, int>? hashCodeFunction;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber =
        DistinctSubscriber<T>(observer, equalsFunction, hashCodeFunction);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class DistinctSubscriber<T> extends Subscriber<T> {
  DistinctSubscriber(Observer<T> super.observer,
      Predicate2<T, T>? equalsFunction, Map1<T, int>? hashCodeFunction)
      : values = HashSet(equals: equalsFunction, hashCode: hashCodeFunction);

  final Set<T> values;

  @override
  void onNext(T value) {
    final addEvent = Event.map1(values.add, value);
    if (addEvent.isError) {
      doError(addEvent.error, addEvent.stackTrace);
    } else if (addEvent.value) {
      doNext(value);
    }
  }
}
