library rx.core.observable;

import 'observer.dart';
import 'operator.dart';
import 'subscriber.dart';
import 'subscription.dart';

typedef SubscribeFunction<T> = dynamic Function(Subscriber<T> subscriber);

abstract class Observable<T> {
  Observable<S> lift<S>(Operator<T, S> operator) =>
      OperatorObservable(this, operator);

  Subscription subscribe(Observer<T> observer);
}

class SubscribeObservable<T> extends Observable<T> {
  final SubscribeFunction<T> subscribeFunction;

  SubscribeObservable(this.subscribeFunction);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = Subscriber<T>(observer);
    try {
      final subscription = subscribeFunction(subscriber);
      subscriber.add(Subscription.of(subscription));
    } catch (error, stackTrace) {
      subscriber.error(error, stackTrace);
    }
    return subscriber;
  }
}

class OperatorObservable<T, S> extends Observable<S> {
  final Observable<T> source;
  final Operator<T, S> operator;

  OperatorObservable(this.source, this.operator);

  @override
  Subscription subscribe(Observer<S> observer) {
    final subscriber = Subscriber<S>(observer);
    subscriber.add(operator.call(source, subscriber));
    return subscriber;
  }
}
