library rx.operators.take_last;

import 'package:collection/collection.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Emits the last [count] values emitted by the source.
Operator<T, T> takeLast<T>([int count = 1]) => (subscriber, source) =>
    source.subscribe(_TakeLastSubscriber(subscriber, count));

class _TakeLastSubscriber<T> extends Subscriber<T> {
  final int count;
  final QueueList<T> buffer;

  _TakeLastSubscriber(Observer<T> destination, this.count)
      : buffer = QueueList(count),
        super(destination);

  @override
  void onNext(T value) {
    while (buffer.length >= count) {
      buffer.removeFirst();
    }
    buffer.addLast(value);
  }

  @override
  void onComplete() {
    buffer.forEach(doNext);
    doComplete();
  }
}
