library rx.core.observer;

import 'package:rx/core.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/base.dart';

void _nextNoop(Object value) {}
void _errorNoop(Object error, [StackTrace stackTrace]) {}
void _completeNoop() {}

abstract class Observer<T> implements Subscription {
  /// An observer with custom handlers.
  factory Observer({
    NextCallback<T> next = _nextNoop,
    ErrorCallback error = _errorNoop,
    CompleteCallback complete = _completeNoop,
  }) =>
      BaseObserver(next, error, complete);

  /// An observer that is only interested in values.
  factory Observer.next(NextCallback<T> next) =>
      BaseObserver(next, _errorNoop, _completeNoop);

  /// An observer that is only interested in failure.
  factory Observer.error(ErrorCallback error) =>
      BaseObserver(_nextNoop, error, _completeNoop);

  /// An observer that is only interested in success.
  factory Observer.complete(CompleteCallback complete) =>
      BaseObserver(_nextNoop, _errorNoop, complete);

  /// Pass a value to the observer.
  void next(T value);

  /// Pass an error to the observer.
  void error(Object error, [StackTrace stackTrace]);

  /// Pass completion to the observer.
  void complete();

  /// Hides the identity of the observer.
  Observer<T> toObserver() => BaseObserver(next, error, complete);
}
