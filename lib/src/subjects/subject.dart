import 'package:meta/meta.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/action.dart';
import '../disposables/disposable.dart';
import '../disposables/disposed.dart';
import '../disposables/errors.dart';

/// A Subject is a special type of [Observable] that allows values to be
/// multicast to many [Observer].
///
/// Every Subject is an [Observable] and an [Observer]. You can subscribe to a
/// [Subject], and you can call `next` to feed values as well as `error` and
/// `complete`.
class Subject<T> implements Observable<T>, Observer<T> {
  final List<Observer<T>> _observers = [];
  bool _isClosed = false;
  bool _hasStopped = false;
  bool _hasError = false;
  late final Object _error;
  late final StackTrace _stackTrace;

  @override
  void next(T value) {
    DisposedError.checkNotDisposed(this);
    if (_hasStopped) return;
    for (final observer in [..._observers]) {
      observer.next(value);
    }
  }

  @override
  void error(Object error, StackTrace stackTrace) {
    DisposedError.checkNotDisposed(this);
    if (_hasStopped) return;
    _hasStopped = true;
    _hasError = true;
    _error = error;
    _stackTrace = stackTrace;
    for (final observer in [..._observers]) {
      observer.error(error, stackTrace);
    }
    _observers.clear();
  }

  @override
  void complete() {
    DisposedError.checkNotDisposed(this);
    if (_hasStopped) return;
    _hasStopped = true;
    for (final observer in [..._observers]) {
      observer.complete();
    }
    _observers.clear();
  }

  @override
  Disposable subscribe(Observer<T> observer) {
    DisposedError.checkNotDisposed(this);
    if (_hasError) {
      return subscribeToError(observer, _error, _stackTrace);
    } else if (_hasStopped) {
      return subscribeToComplete(observer);
    } else {
      return subscribeToActive(observer);
    }
  }

  @protected
  Disposable subscribeToActive(Observer<T> observer) {
    _observers.add(observer);
    return ActionDisposable(() => _observers.remove(observer));
  }

  @protected
  Disposable subscribeToError(
      Observer<T> observer, Object error, StackTrace stackTrace) {
    observer.error(error, stackTrace);
    return const DisposedDisposable();
  }

  @protected
  Disposable subscribeToComplete(Observer<T> observer) {
    observer.complete();
    return const DisposedDisposable();
  }

  @override
  bool get isDisposed => _isClosed;

  bool get isObserved => _observers.isNotEmpty;

  @override
  void dispose() {
    _isClosed = true;
    _hasStopped = true;
    _observers.clear();
  }
}
