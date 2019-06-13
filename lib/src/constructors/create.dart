library rx.constructors.create;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

typedef SubscribeFunction<T> = dynamic Function(Subscriber<T> subscriber);

/// Creates an observable sequence from a specified subscribe method
/// implementation.
Observable<T> create<T>(SubscribeFunction<T> subscribeFunction) =>
    _SubscribeObservable<T>(subscribeFunction);

class _SubscribeObservable<T> extends Observable<T> {
  final SubscribeFunction<T> subscribeFunction;

  _SubscribeObservable(this.subscribeFunction);

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
