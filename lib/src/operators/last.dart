library rx.operators.last;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef LastCallback<T> = T Function();

/// Returns the last element of an observable sequence, or emits an [EmptyError]
/// otherwise.
Operator<T, T> last<T>() => lastOrElse(() => throw EmptyError());

/// Returns the last element of an observable sequence, or the provided default
/// value otherwise.
Operator<T, T> lastOrDefault<T>([T value]) => lastOrElse(() => value);

/// Returns the last element of an observable sequence, or evaluates the
/// provided callback otherwise.
Operator<T, T> lastOrElse<T>(LastCallback<T> callback) =>
    (subscriber, source) =>
        source.subscribe(_LastSubscriber(subscriber, callback));

class _LastSubscriber<T> extends Subscriber<T> {
  final LastCallback<T> callback;

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
    if (!seenValue) {
      try {
        onNext(callback());
      } catch (error, stackTrace) {
        doError(error, stackTrace);
        return;
      }
    }
    doNext(lastValue);
    doComplete();
  }
}
