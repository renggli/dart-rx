library rx.operators.first_or_default;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Returns the first element of an observable sequence, or a default value if
/// the sequence is empty.
Operator<T, T> firstOrDefault<T>([T defaultValue]) =>
    _FirstOrDefaultOperator(defaultValue);

class _FirstOrDefaultOperator<T> implements Operator<T, T> {
  final T defaultValue;

  _FirstOrDefaultOperator(this.defaultValue);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_FirstOrDefaultSubscriber(destination, defaultValue));
}

class _FirstOrDefaultSubscriber<T> extends Subscriber<T> {
  final T defaultValue;

  _FirstOrDefaultSubscriber(Observer<T> destination, this.defaultValue)
      : super(destination);

  @override
  void onNext(T value) {
    doNext(value);
    doComplete();
  }

  @override
  void onComplete() {
    doNext(defaultValue);
    doComplete();
  }
}
