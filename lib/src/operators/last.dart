library rx.operators.last;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Return the last item of an observable sequence, or emits an
/// [TooFewError] otherwise.
Map1<Observable<T>, Observable<T>> last<T>() =>
    lastOrElse<T>(throwFunction0(TooFewError()));

/// Return the last item of an observable sequence, or the provided
/// default [value] otherwise.
Map1<Observable<T>, Observable<T>> lastOrDefault<T>([T value]) =>
    lastOrElse<T>(constantFunction0(value));

/// Return the last item of an observable sequence, or evaluate the
/// provided [callback] otherwise.
Map1<Observable<T>, Observable<T>> lastOrElse<T>(Map0<T> callback) =>
    findLastOrElse<T>(constantFunction1(true), callback);

/// Return the last item an observable sequence matching the [predicate], or
/// emits an [TooFewError] otherwise.
Map1<Observable<T>, Observable<T>> findLast<T>(Predicate1<T> predicate) =>
    findLastOrElse<T>(predicate, throwFunction0(TooFewError()));

/// Return the last item an observable sequence matching the [predicate], or
/// the provided default [value] otherwise.
Map1<Observable<T>, Observable<T>> findLastOrDefault<T>(Predicate1<T> predicate,
        [T value]) =>
    findLastOrElse<T>(predicate, constantFunction0(value));

/// Return the last item an observable sequence matching the [predicate], or
/// evaluate the provided [callback] otherwise.
Map1<Observable<T>, Observable<T>> findLastOrElse<T>(
        Predicate1<T> predicate, Map0<T> callback) =>
    (source) => source.lift((source, subscriber) => source
        .subscribe(_FindLastSubscriber<T>(subscriber, predicate, callback)));

class _FindLastSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;
  final Map0<T> callback;

  T lastValue;
  bool seenValue = false;

  _FindLastSubscriber(Observer<T> destination, this.predicate, this.callback)
      : super(destination);

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent is ErrorEvent) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      lastValue = value;
      seenValue = true;
    }
  }

  @override
  void onComplete() {
    if (seenValue) {
      doNext(lastValue);
      doComplete();
    } else {
      final resultEvent = Event.map0(callback);
      if (resultEvent is ErrorEvent) {
        doError(resultEvent.error, resultEvent.stackTrace);
      } else {
        doNext(resultEvent.value);
        doComplete();
      }
    }
  }
}
