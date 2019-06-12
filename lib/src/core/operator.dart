library rx.core.operator;

import 'observable.dart';
import 'subscriber.dart';
import 'subscription.dart';

typedef Operator<T, R> = Subscription Function(
    Subscriber<R> subscriber, Observable<T> source);
