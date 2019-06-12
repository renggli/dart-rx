library rx.operators.first_or_default;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Returns the first element of an observable sequence, or a default value if
/// the sequence is empty.
Operator<T, T> firstOrDefault<T>([T defaultValue]) => (subscriber, source) =>
    source.subscribe(_FirstOrDefaultSubscriber(subscriber, defaultValue));

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
