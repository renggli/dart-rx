library rx.observables.connectable;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/subscriptions.dart';

abstract class ConnectableObservable<T> extends Observable<T> {
  Subscription connect();
}
