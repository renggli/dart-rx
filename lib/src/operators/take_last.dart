library rx.operators.take_last;

import 'package:collection/collection.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

extension TakeLastOperator<T> on Observable<T> {
  /// Emits the last [count] values emitted by the source.
  Observable<T> takeLast([int count = 1]) => TakeLastObservable<T>(this, count);
}

class TakeLastObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final int count;

  TakeLastObservable(this.delegate, this.count);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = TakeLastSubscriber<T>(observer, count);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TakeLastSubscriber<T> extends Subscriber<T> {
  final int count;
  final QueueList<T> buffer;

  TakeLastSubscriber(Observer<T> destination, this.count)
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
