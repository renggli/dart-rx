library rx.operators.multicast;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subject.dart';
import '../disposables/disposable.dart';
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
  Disposable _subscription = Disposable.empty();

  MulticastObservable(this._source, this._factory);

  Subject<T> get subject => _subject ??= _factory();

  @override
  Disposable connect() {
    if (!_isConnected) {
      _isConnected = true;
      _subscription = Disposable.composite([
        _source.subscribe(subject),
        Disposable.create(() => _isConnected = false),
      ]);
    }
    return _subscription;
  }

  @override
  Disposable subscribe(Observer<T> observer) => subject.subscribe(observer);
}
