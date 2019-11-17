library rx.core.observer;

import '../disposables/disposable.dart';
import '../observers/base.dart';
import '../shared/functions.dart';

abstract class Observer<T> implements Disposable {
  /// An observer with custom handlers.
  factory Observer({
    NextCallback<T> next = nullFunction1,
    ErrorCallback error = nullFunction2,
    CompleteCallback complete = nullFunction0,
  }) =>
      BaseObserver<T>(next, error, complete);

  /// An observer that is only interested in values.
  factory Observer.next(NextCallback<T> next) =>
      BaseObserver<T>(next, nullFunction2, nullFunction0);

  /// An observer that is only interested in failure.
  factory Observer.error(ErrorCallback error) =>
      BaseObserver<T>(nullFunction1, error, nullFunction0);

  /// An observer that is only interested in success.
  factory Observer.complete(CompleteCallback complete) =>
      BaseObserver<T>(nullFunction1, nullFunction2, complete);

  /// Pass a value to the observer.
  void next(T value);

  /// Pass an error to the observer.
  void error(Object error, [StackTrace stackTrace]);

  /// Pass completion to the observer.
  void complete();
}
