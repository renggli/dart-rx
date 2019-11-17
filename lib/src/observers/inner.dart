library rx.observers.base;

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';

/// Observes an inner [Observable] and passes the events to an outer object
/// with optional state.
class InnerObserver<T, S> with Observer<T> implements Observer<T> {
  final InnerEvents<T, S> _outer;
  final S _state;
  Disposable _subscription;

  InnerObserver(Observable<T> inner, this._outer, [this._state]) {
    _subscription = inner.subscribe(this);
  }

  @override
  void next(T value) => _outer.notifyNext(this, _state, value);

  @override
  void error(Object error, [StackTrace stackTrace]) =>
      _outer.notifyError(this, _state, error, stackTrace);

  @override
  void complete() => _outer.notifyComplete(this, _state);

  @override
  bool get isDisposed => _subscription.isDisposed;

  @override
  void dispose() => _subscription.dispose();
}

/// Interface to receive events from an [InnerObserver].
abstract class InnerEvents<T, S> {
  void notifyNext(Disposable subscription, S state, T value);

  void notifyError(Disposable subscription, S state, Object error,
      [StackTrace stackTrace]);

  void notifyComplete(Disposable subscription, S state);
}
