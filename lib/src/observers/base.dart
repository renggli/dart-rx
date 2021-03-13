import 'package:meta/meta.dart';

import '../core/observer.dart';
import '../shared/functions.dart';

class BaseObserver<T> with Observer<T> implements Observer<T> {
  final NextCallback<T> _next;
  final ErrorCallback _error;
  final CompleteCallback _complete;

  bool _isClosed = false;

  BaseObserver(this._next, this._error, this._complete);

  @override
  void next(T value) {
    if (!_isClosed) {
      onNext(value);
    }
  }

  @protected
  void onNext(T value) => _next(value);

  @override
  void error(Object error, StackTrace stackTrace) {
    if (!_isClosed) {
      _isClosed = true;
      onError(error, stackTrace);
    }
  }

  @protected
  void onError(Object error, StackTrace stackTrace) =>
      _error(error, stackTrace);

  @override
  void complete() {
    if (!_isClosed) {
      _isClosed = true;
      onComplete();
    }
  }

  @protected
  void onComplete() => _complete();

  @override
  bool get isDisposed => _isClosed;

  @override
  void dispose() => _isClosed = true;
}
