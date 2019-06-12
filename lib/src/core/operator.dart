library rx.core.operator;

import 'observable.dart';
import 'observer.dart';
import 'subscription.dart';

typedef Operator<T, R> = Subscription Function(
    Observable<T> source, Observer<R> destination);
