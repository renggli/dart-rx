library rx.observers.base;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscription.dart';

/// Observes an inner [Observable] and passes the events to an outer object
/// with optional state.
class InnerObserver<T, S> with Observer<T> implements Observer<T> {
  final InnerEvents<T, S> _outer;
  final S _state;
  Subscription _subscription;

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
  bool get isClosed => _subscription.isClosed;

  @override
  void unsubscribe() => _subscription.unsubscribe();
}

/// Interface to receive events from an [InnerObserver].
abstract class InnerEvents<T, S> {
  void notifyNext(Subscription subscription, S state, T value);

  void notifyError(Subscription subscription, S state, Object error,
      [StackTrace stackTrace]);

  void notifyComplete(Subscription subscription, S state);
}
