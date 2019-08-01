library rx.observables.connectable;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subject.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';
import 'package:rx/subscriptions.dart';

class ConnectableObservable<T> extends Observable<T> {
  final Observable<T> _source;
  final Map0<Subject<T>> _factory;
  Subject<T> _subject;
  bool _isConnected = false;
  Subscription _subscription = Subscription.empty();

  ConnectableObservable(this._source, this._factory);

  Subject<T> get subject => _subject ??= _factory();

  Subscription connect() {
    if (!_isConnected) {
      _isConnected = true;
      _subscription = Subscription.composite([
        _source.subscribe(subject),
        Subscription.create(() => _isConnected = false),
      ]);
    }
    return _subscription;
  }

  @override
  Subscription subscribe(Observer<T> observer) => subject.subscribe(observer);
}
