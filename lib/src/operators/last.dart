library rx.operators.last;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/functions.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Returns the last element of an observable sequence, or emits an
/// [TooFewError] otherwise.
Operator<T, T> last<T>() => lastOrElse(() => throw TooFewError());

/// Returns the last element of an observable sequence, or the provided default
/// value otherwise.
Operator<T, T> lastOrDefault<T>([T value]) => lastOrElse(() => value);

/// Returns the last element of an observable sequence, or evaluates the
/// provided callback otherwise.
Operator<T, T> lastOrElse<T>(Map0<T> callback) => (subscriber, source) =>
    source.subscribe(_LastSubscriber(subscriber, callback));

class _LastSubscriber<T> extends Subscriber<T> {
  final Map0<T> callback;

  T lastValue;
  bool seenValue = false;

  _LastSubscriber(Observer<T> destination, this.callback) : super(destination);

  @override
  void onNext(T value) {
    lastValue = value;
    seenValue = true;
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
