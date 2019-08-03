library rx.operators.first;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Return the first item of an observable sequence, or emits an
/// [TooFewError] otherwise.
Map1<Observable<T>, Observable<T>> first<T>() =>
    firstOrElse<T>(throwFunction0(TooFewError()));

/// Return the first item of an observable sequence, or the provided
/// default [value] otherwise.
Map1<Observable<T>, Observable<T>> firstOrDefault<T>([T value]) =>
    firstOrElse<T>(constantFunction0(value));

/// Return the first item of an observable sequence, or evaluate the
/// provided [callback] otherwise.
Map1<Observable<T>, Observable<T>> firstOrElse<T>(Map0<T> callback) =>
    findFirstOrElse<T>(constantFunction1(true), callback);

/// Return the first item an observable sequence matching the [predicate], or
/// emits an [TooFewError] otherwise.
Map1<Observable<T>, Observable<T>> findFirst<T>(Predicate1<T> predicate) =>
    findFirstOrElse<T>(predicate, throwFunction0(TooFewError()));

/// Return the first item an observable sequence matching the [predicate], or
/// the provided default [value] otherwise.
Map1<Observable<T>, Observable<T>> findFirstOrDefault<T>(
        Predicate1<T> predicate,
        [T value]) =>
    findFirstOrElse<T>(predicate, constantFunction0(value));

/// Return the first item an observable sequence matching the [predicate], or
/// evaluate the provided [callback] otherwise.
Map1<Observable<T>, Observable<T>> findFirstOrElse<T>(
        Predicate1<T> predicate, Map0<T> callback) =>
    (source) => source.lift((source, subscriber) => source
        .subscribe(_FindFirstSubscriber<T>(subscriber, predicate, callback)));

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
