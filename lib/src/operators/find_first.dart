library rx.operators.find_first;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Return the first item of an observable sequence, or emits an
/// [TooFewError] otherwise.
Operator<T, T> first<T>() => firstOrElse(throwFunction0(TooFewError()));

/// Return the first item of an observable sequence, or the provided
/// default [value] otherwise.
Operator<T, T> firstOrDefault<T>([T value]) =>
    firstOrElse(constantFunction0(value));

/// Return the first item of an observable sequence, or evaluate the
/// provided [callback] otherwise.
Operator<T, T> firstOrElse<T>(Map0<T> callback) =>
    findFirstOrElse<T>(constantFunction1(true), callback);

/// Return the first item an observable sequence matching the [predicate], or
/// emits an [TooFewError] otherwise.
Operator<T, T> findFirst<T>(Predicate1<T> predicate) =>
    findFirstOrElse(predicate, throwFunction0(TooFewError()));

/// Return the first item an observable sequence matching the [predicate], or
/// the provided default [value] otherwise.
Operator<T, T> findFirstOrDefault<T>(Predicate1<T> predicate, [T value]) =>
    findFirstOrElse(predicate, constantFunction0(value));

/// Return the first item an observable sequence matching the [predicate], or
/// evaluate the provided [callback] otherwise.
Operator<T, T> findFirstOrElse<T>(Predicate1<T> predicate, Map0<T> callback) =>
    (subscriber, source) =>
        source.subscribe(_FindFirstSubscriber(subscriber, predicate, callback));

class _FindFirstSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;
  final Map0<T> callback;

  _FindFirstSubscriber(Observer<T> destination, this.predicate, this.callback)
      : super(destination);

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent is ErrorEvent) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      doNext(value);
      doComplete();
    }
  }

  @override
  void onComplete() {
    final resultEvent = Event.map0(callback);
    if (resultEvent is ErrorEvent) {
      doError(resultEvent.error, resultEvent.stackTrace);
    } else {
      doNext(resultEvent.value);
      doComplete();
    }
  }
}
