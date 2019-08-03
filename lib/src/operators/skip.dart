library rx.operators.skip;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Skips over the first [count] values before starting to emit.
OperatorFunction<T, T> skip<T>([int count = 1]) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_SkipSubscriber<T>(subscriber, count)));

class _SkipSubscriber<T> extends Subscriber<T> {
  int count = 0;

  _SkipSubscriber(Observer<T> destination, this.count) : super(destination);

  @override
  void onNext(T value) {
    if (count > 0) {
      count--;
    } else {
      doNext(value);
    }
  }
}
