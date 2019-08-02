library rx.subjects.async;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subject.dart';
import 'package:rx/src/core/subscription.dart';

/// A [Subject] that emits its last value to all its subscribers on completion.
class AsyncSubject<T> extends Subject<T> {
  T _value;
  bool _hasValue = false;
  bool _hasCompleted = false;

  @override
  void next(T value) {
    if (!_hasCompleted) {
      _value = value;
      _hasValue = true;
    }
  }

  @override
  void error(Object error, [StackTrace stackTrace]) {
    if (!_hasCompleted) {
      super.error(error, stackTrace);
    }
  }

  @override
  void complete() {
    _hasCompleted = true;
    if (_hasValue) {
      super.next(_value);
      super.complete();
    }
  }

  @override
  Subscription subscribe(Observer<T> observer) {
    if (_hasCompleted && _hasValue) {
      observer.next(_value);
      observer.complete();
      return Subscription.empty();
    }
    return super.subscribe(observer);
  }
}
