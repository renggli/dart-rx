library rx.operators.find_last;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Return the last item of an observable sequence, or emits an
/// [TooFewError] otherwise.
Operator<T, T> last<T>() => lastOrElse(throwFunction0(TooFewError()));

/// Return the last item of an observable sequence, or the provided
/// default [value] otherwise.
Operator<T, T> lastOrDefault<T>([T value]) =>
    lastOrElse(constantFunction0(value));

/// Return the last item of an observable sequence, or evaluate the
/// provided [callback] otherwise.
Operator<T, T> lastOrElse<T>(Map0<T> callback) =>
    findLastOrElse<T>(constantFunction1(true), callback);

/// Return the last item an observable sequence matching the [predicate], or
/// emits an [TooFewError] otherwise.
Operator<T, T> findLast<T>(Predicate1<T> predicate) =>
    findLastOrElse(predicate, throwFunction0(TooFewError()));

/// Return the last item an observable sequence matching the [predicate], or
/// the provided default [value] otherwise.
Operator<T, T> findLastOrDefault<T>(Predicate1<T> predicate, [T value]) =>
    findLastOrElse(predicate, constantFunction0(value));

/// Return the last item an observable sequence matching the [predicate], or
/// evaluate the provided [callback] otherwise.
Operator<T, T> findLastOrElse<T>(Predicate1<T> predicate, Map0<T> callback) =>
    (subscriber, source) =>
        source.subscribe(_FindLastSubscriber(subscriber, predicate, callback));

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
