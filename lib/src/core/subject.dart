library rx.core.subject;

import 'package:meta/meta.dart';
import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/subscription.dart';

import 'observable.dart';
import 'observer.dart';

/// A Subject is a special type of [Observable] that allows values to be
/// multicast to many [Observer].
///
/// Every Subject is an [Observable] and an [Observer]. You can subscribe to a
/// [Subject], and you can call `next` to feed values as well as `error` and
/// `complete`.
class Subject<T>
    with Observable<T>
    implements Observable<T>, Observer<T>, Subscription {
  final List<Observer<T>> _observers = [];
  bool _isClosed = false;
  bool _hasStopped = false;
  bool _hasError = false;
  Object _error;
  StackTrace _stackTrace;

  @override
  void next(T value) {
    UnsubscribedError.checkOpen(this);
    if (_hasStopped) {
      return;
    }
    final observers = [..._observers];
    for (final observer in observers) {
      observer.next(value);
    }
  }

  @override
  void error(Object error, [StackTrace stackTrace]) {
    UnsubscribedError.checkOpen(this);
    if (_hasStopped) {
      return;
    }
    _hasStopped = true;
    _hasError = true;
    _error = error;
    _stackTrace = stackTrace;
    final observers = [..._observers];
    for (final observer in observers) {
      observer.error(error, stackTrace);
    }
    _observers.clear();
  }

  @override
  void complete() {
    UnsubscribedError.checkOpen(this);
    if (_hasStopped) {
      return;
    }
    _hasStopped = true;
    final observers = [..._observers];
    for (final observer in observers) {
      observer.complete();
    }
    _observers.clear();
  }

  @override
  Subscription subscribe(Observer<T> observer) {
    UnsubscribedError.checkOpen(this);
    if (_hasError) {
      return subscribeToError(observer, _error, _stackTrace);
    } else if (_hasStopped) {
      return subscribeToComplete(observer);
    } else {
      return subscribeToActive(observer, _observers);
    }
  }

  @protected
  Subscription subscribeToActive(
      Observer observer, List<Observer<T>> observers) {
    observers.add(observer);
    return Subscription.create(() => observers.remove(observer));
  }

  @protected
  Subscription subscribeToError(
      Observer observer, Object error, StackTrace stackTrace) {
    observer.error(error, stackTrace);
    return Subscription.closed();
  }

  @protected
  Subscription subscribeToComplete(Observer observer) {
    observer.complete();
    return Subscription.closed();
  }

  @override
  bool get isClosed => _isClosed;

  @override
  void unsubscribe() {
    _isClosed = true;
    _hasStopped = true;
    _observers.clear();
  }
}
