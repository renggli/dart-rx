library rx.operators.take;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Emits the first [count] values before completing.
OperatorFunction<T, T> take<T>([int count = 1]) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_TakeSubscriber<T>(subscriber, count)));

class _TakeSubscriber<T> extends Subscriber<T> {
  int count;

  _TakeSubscriber(Observer<T> destination, this.count) : super(destination);

  @override
  void onNext(T value) {
    doNext(value);
    if (--count <= 0) {
      doComplete();
    }
  }
}
