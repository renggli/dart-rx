library rx.core.operator;

import 'observable.dart';
import 'observer.dart';
import 'subscription.dart';

abstract class Operator<T, S> {
  Subscription call(Observable<T> source, Observer<S> destination);
}
