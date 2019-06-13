library rx.core.observable;

import 'observer.dart';
import 'operator.dart';
import 'subscriber.dart';
import 'subscription.dart';

abstract class Observable<T> {
  Observable<S> lift<S>(Operator<T, S> operator) =>
      _OperatorObservable(this, operator);

  Subscription subscribe(Observer<T> observer);
}

class _OperatorObservable<T, R> extends Observable<R> {
  final Observable<T> source;
  final Operator<T, R> operator;

  _OperatorObservable(this.source, this.operator);

  @override
  Subscription subscribe(Observer<R> observer) {
    final subscriber = Subscriber<R>(observer);
    subscriber.add(operator.call(subscriber, source));
    return subscriber;
  }
}
