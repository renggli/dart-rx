library rx.operators.last_or_default;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Returns the last element of an observable sequence, or a default value if
/// the sequence is empty.
Operator<T, T> lastOrDefault<T>([T defaultValue]) => (source, destination) =>
    source.subscribe(_LastOrDefaultSubscriber(destination, defaultValue));

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
    doNext(seenValue ? lastValue : defaultValue);
    doComplete();
  }
}
