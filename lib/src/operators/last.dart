library rx.operators.last;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Returns the last element of an observable sequence.
Operator<T, T> last<T>() => _LastOperator();

class _LastOperator<T> implements Operator<T, T> {
  _LastOperator();

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_LastSubscriber(destination));
}

class _LastSubscriber<T> extends Subscriber<T> {
  T lastValue;
  bool seenValue = false;

  _LastSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(T value) {
    lastValue = value;
    seenValue = true;
  }

  @override
  void onComplete() {
    if (seenValue) {
      destination.next(seenValue);
      super.onComplete();
    } else {
      super.onError('Sequence contains no elements');
    }
  }
}
