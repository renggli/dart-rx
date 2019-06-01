library rx.core.observable;

import 'observer.dart';
import 'operator.dart';
import 'subscriber.dart';
import 'subscription.dart';

typedef SubscribeFunction<T> = void Function(Subscriber<T> subscriber);

abstract class Observable<T> {
  factory Observable(SubscribeFunction<T> subscribeFunction) =>
      SubscribeObservable(subscribeFunction);

  Observable<S> lift<S>(Operator<T, S> operator) =>
      OperatorObservable(this, operator);

  Subscription subscribe(Observer<T> observer);
}

class SubscribeObservable<T> with Observable<T> {
  final SubscribeFunction<T> subscribeFunction;

  SubscribeObservable(this.subscribeFunction);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = Subscriber<T>(
        AnonymousObserver<T>(observer.next, observer.error, observer.complete));
    subscribeFunction(subscriber);
    return subscriber;
  }
}

class OperatorObservable<T, S> with Observable<S> {
  final Observable<T> source;
  final Operator<T, S> operator;

  OperatorObservable(this.source, this.operator);

  @override
  Subscription subscribe(Observer<S> observer) =>
      operator.call(source, observer);
}
