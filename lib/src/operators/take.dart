library rx.operators.take;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

extension TakeOperator<T> on Observable<T> {
  /// Emits the first [count] values before completing.
  Observable<T> take([int count = 1]) => TakeObservable<T>(this, count);
}

class TakeObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final int count;

  TakeObservable(this.delegate, this.count);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(TakeSubscriber<T>(observer, count));
}

class TakeSubscriber<T> extends Subscriber<T> {
  int count;

  TakeSubscriber(Observer<T> observer, this.count) : super(observer);

  @override
  void onNext(T value) {
    doNext(value);
    if (--count <= 0) {
      doComplete();
    }
  }
}
