library rx.operators.default_if_empty;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Emits a given value if the source completes without emitting any value,
/// otherwise mirrors the source.
Operator<T, T> defaultIfEmpty<T>([T value]) => (subscriber, source) =>
    source.subscribe(_DefaultIfEmptySubscriber(subscriber, value));

class _DefaultIfEmptySubscriber<T> extends Subscriber<T> {
  final T defaultValue;

  bool seenValue = false;

  _DefaultIfEmptySubscriber(Observer<T> destination, this.defaultValue)
      : super(destination);

  @override
  void onNext(T value) {
    seenValue = true;
    doNext(value);
  }

  @override
  void onComplete() {
    if (!seenValue) {
      doNext(defaultValue);
    }
    doComplete();
  }
}
