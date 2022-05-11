import 'package:collection/collection.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension TakeLastOperator<T> on Observable<T> {
  /// Emits the last [count] values emitted by the source.
  Observable<T> takeLast([int count = 1]) => TakeLastObservable<T>(this, count);
}

class TakeLastObservable<T> implements Observable<T> {
  TakeLastObservable(this.delegate, this.count);

  final Observable<T> delegate;
  final int count;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = TakeLastSubscriber<T>(observer, count);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TakeLastSubscriber<T> extends Subscriber<T> {
  TakeLastSubscriber(Observer<T> super.destination, this.count)
      : buffer = QueueList(count);

  final int count;
  final QueueList<T> buffer;

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
    buffer.clear();
    doComplete();
  }
}
