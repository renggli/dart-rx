library rx.observables.connectable;

import '../../subscriptions.dart';
import '../core/observable.dart';
import '../core/subscription.dart';

abstract class ConnectableObservable<T> extends Observable<T> {
  Subscription connect();
}
