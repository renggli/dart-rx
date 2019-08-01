library rx.observables.connectable;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subject.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/subscriptions.dart';

class ConnectableObservable<T> extends Observable<T> {
  final Observable<T> source;
  final Subject<T> subject;

  bool _isConnected = false;
  Subscription _subscription = Subscription.empty();

  ConnectableObservable(this.source, this.subject);

  Subscription connect() {
    if (!_isConnected) {
      _isConnected = true;
      _subscription = Subscription.composite([
        source.subscribe(subject),
        Subscription.create(() => _isConnected = false),
      ]);
    }
    return _subscription;
  }

  @override
  Subscription subscribe(Observer<T> observer) => subject.subscribe(observer);
}
