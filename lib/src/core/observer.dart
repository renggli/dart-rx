library rx.core.observer;

import 'package:rx/core.dart';

void _nextFunctionDefault(Object value) {}
void _errorFunctionDefault(Object error, [StackTrace stackTrace]) {}
void _completeFunctionDefault() {}

abstract class Observer<T> {
  factory Observer({
    NextFunction<T> next = _nextFunctionDefault,
    ErrorFunction error = _errorFunctionDefault,
    CompleteFunction complete = _completeFunctionDefault,
  }) =>
      PluggableObserver(next, error, complete);

  void next(T value);

  void error(Object error, [StackTrace stackTrace]);

  void complete();
}

class PluggableObserver<T> implements Observer<T> {
  final NextFunction<T> _nextFunction;
  final ErrorFunction _errorFunction;
  final CompleteFunction _completeFunction;

  PluggableObserver(
      [this._nextFunction, this._errorFunction, this._completeFunction]);

  @override
  void next(T value) => _nextFunction(value);

  @override
  void error(Object error, [StackTrace stackTrace]) =>
      _errorFunction(error, stackTrace);

  @override
  void complete() => _completeFunction();
}

class DelegateOberver<T> implements Observer<T> {
  final Observer<T> _delegate;

  DelegateOberver(this._delegate);

  @override
  void next(T value) => _delegate.next(value);

  @override
  void error(Object error, [StackTrace stackTrace]) =>
      _delegate.error(error, stackTrace);

  @override
  void complete() => _delegate.complete();
}
