library rx.core.operator;

import 'observable.dart';
import 'subscriber.dart';
import 'subscription.dart';

typedef Operator<T, R> = Subscription Function(
    Observable<T> source, Subscriber<R> subscriber);

typedef OperatorFunction<T, R> = Observable<R> Function(Observable<T> source);
