library rx.operators.take;

import 'package:rx/core.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';

/// Emits the first [count] values before completing.
Operator<T, T> take<T>([int count = 1]) => (source, destination) =>
    source.subscribe(_TakeSubscriber(destination, count));

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
