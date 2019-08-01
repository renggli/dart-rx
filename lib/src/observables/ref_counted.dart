library rx.observables.ref_counted;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/subscriptions.dart';

import 'connectable.dart';

class RefCountedObservable<T> extends Observable<T> {
  final ConnectableObservable<T> observable;

  Subscription _subscription = Subscription.empty();
  int _count = 0;

  RefCountedObservable(this.observable);

  @override
  Subscription subscribe(Observer<T> observer) {
    if (_count == 0) {
      _subscription = observable.connect();
    }
    _count++;
    return Subscription.create(() {
      _count--;
      if (_count == 0) {
        _subscription.unsubscribe();
        _subscription = Subscription.empty();
      }
    });
  }
}
