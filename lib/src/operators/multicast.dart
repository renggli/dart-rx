import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/action.dart';
import '../disposables/composite.dart';
import '../disposables/disposable.dart';
import '../disposables/disposed.dart';
import '../observables/connectable.dart';
import '../subjects/subject.dart';

extension MulticastOperator<T> on Observable<T> {
  /// Returns an multicast observable that shares the underlying stream.
  ConnectableObservable<T> multicast(
      {Subject<T>? subject, Map0<Subject<T>>? factory}) {
    if (subject != null && factory != null) {
      throw ArgumentError.value(
          subject, 'subject', 'Subject and factory cannot both be given.');
    }
    factory ??= () => subject ?? Subject<T>();
    return MulticastObservable<T>(this, factory);
  }
}

class MulticastObservable<T>
    implements Observable<T>, ConnectableObservable<T> {
  MulticastObservable(this._source, this._factory);

  final Observable<T> _source;
  final Map0<Subject<T>> _factory;

  Subject<T>? _subject;
  Disposable _subscription = const DisposedDisposable();

  Subject<T> get subject => _subject ??= _factory();

  @override
  bool isConnected = false;

  @override
  Disposable connect() {
    if (!isConnected) {
      isConnected = true;
      _subscription = CompositeDisposable([
        _source.subscribe(subject),
        ActionDisposable(() => isConnected = false),
      ]);
    }
    return _subscription;
  }

  @override
  Disposable subscribe(Observer<T> observer) => subject.subscribe(observer);
}
