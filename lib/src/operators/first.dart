library rx.operators.first;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/functions.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Returns the first element of an observable sequence, or emits an
/// [TooFewError] otherwise.
Operator<T, T> first<T>() => firstOrElse(() => throw TooFewError());

/// Returns the first element of an observable sequence, or the provided
/// default value otherwise.
Operator<T, T> firstOrDefault<T>([T value]) => firstOrElse(() => value);

/// Returns the first element of an observable sequence, or evaluates the
/// provided callback otherwise.
Operator<T, T> firstOrElse<T>(Map0<T> callback) => (subscriber, source) =>
    source.subscribe(_FirstSubscriber(subscriber, callback));

class _FirstSubscriber<T> extends Subscriber<T> {
  final Map0<T> callback;

  _FirstSubscriber(Observer<T> destination, this.callback) : super(destination);

  @override
  void onNext(T value) {
    doNext(value);
    doComplete();
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
