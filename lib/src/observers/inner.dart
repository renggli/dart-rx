import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';

/// Observes an inner [Observable] and passes the events to an outer object
/// with optional state.
class InnerObserver<T, S> implements Observer<T> {
  InnerObserver(this._outer, Observable<T> inner, this._state) {
    _disposable = inner.subscribe(this);
  }

  final InnerEvents<T, S> _outer;
  final S _state;
  late final Disposable _disposable;

  @override
  void next(T value) => _outer.notifyNext(this, _state, value);

  @override
  void error(Object error, StackTrace stackTrace) =>
      _outer.notifyError(this, _state, error, stackTrace);

  @override
  void complete() => _outer.notifyComplete(this, _state);

  @override
  bool get isDisposed => _disposable.isDisposed;

  @override
  void dispose() => _disposable.dispose();
}

/// Interface to receive events from an [InnerObserver].
abstract class InnerEvents<T, S> {
  void notifyNext(Disposable disposable, S state, T value);

  void notifyError(
      Disposable disposable, S state, Object error, StackTrace stackTrace);

  void notifyComplete(Disposable disposable, S state);
}
