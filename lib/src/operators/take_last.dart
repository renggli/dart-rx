library rx.operators.take_last;

import 'package:collection/collection.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Emits the last [count] values emitted by the source.
Map1<Observable<T>, Observable<T>> takeLast<T>([int count = 1]) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_TakeLastSubscriber<T>(subscriber, count)));

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
