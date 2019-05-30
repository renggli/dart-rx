library rx.operators.last_or_default;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Returns the last element of an observable sequence, or a default value if
/// the sequence is empty.
Operator<T, T> lastOrDefault<T>([T defaultValue]) =>
    _LastOrDefaultOperator(defaultValue);

class _LastOrDefaultOperator<T> implements Operator<T, T> {
  final T defaultValue;

  _LastOrDefaultOperator(this.defaultValue);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_LastOrDefaultSubscriber(destination, defaultValue));
}

class _LastOrDefaultSubscriber<T> extends Subscriber<T> {
  final T defaultValue;
  T lastValue;
  bool seenValue = false;

  _LastOrDefaultSubscriber(Observer<T> destination, this.defaultValue)
      : super(destination);

  @override
  void onNext(T value) {
    lastValue = value;
    seenValue = true;
  }

  @override
  void onComplete() {
    destination.next(seenValue ? lastValue : defaultValue);
    super.onComplete();
  }
}
