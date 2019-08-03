library rx.core.observable;

import 'package:rx/src/shared/functions.dart';

import 'observer.dart';
import 'operator.dart';
import 'subscriber.dart';
import 'subscription.dart';

abstract class Observable<T> {
  /// Creates a new observable with the provided [operator].
  Observable<R> lift<R>(Operator<T, R> operator) =>
      _OperatorObservable(this, operator);

  /// Creates a new observable by chaining a sequence of operator functions.
  R pipe<R>(Map1<Observable<T>, R> operatorFunction) => operatorFunction(this);

  /// Subscribes with the provided [observer].
  Subscription subscribe(Observer<T> observer);
}

class _OperatorObservable<T, R> extends Observable<R> {
  final Observable<T> source;
  final Operator<T, R> operator;

  _OperatorObservable(this.source, this.operator);

  @override
  Subscription subscribe(Observer<R> observer) {
    final subscriber = Subscriber<R>(observer);
    subscriber.add(operator(source, subscriber));
    return subscriber;
  }
}
