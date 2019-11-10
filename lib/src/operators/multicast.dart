library rx.operators.multicast;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subject.dart';
import '../core/subscription.dart';
import '../observables/connectable.dart';
import '../shared/functions.dart';

extension MulticastOperator<T> on Observable<T> {
  /// Returns an multicast observable that shares the underlying stream.
  ConnectableObservable<T> multicast(
      {Subject<T> subject, Map0<Subject<T>> factory}) {
    if (subject != null && factory != null) {
      throw ArgumentError.value(
          subject, 'subject', 'Subject and factory cannot both be given.');
    }
    factory ??= () => subject ?? Subject<T>();
    return MulticastObservable<T>(this, factory);
  }
}

class MulticastObservable<T> extends Observable<T>
    implements ConnectableObservable<T> {
  final Observable<T> _source;
  final Map0<Subject<T>> _factory;

  Subject<T> _subject;
  bool _isConnected = false;
  Subscription _subscription = Subscription.empty();

  MulticastObservable(this._source, this._factory);

  Subject<T> get subject => _subject ??= _factory();

  @override
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
