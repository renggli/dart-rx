library rx.core.observer;

import '../disposables/disposable.dart';
import '../observers/base.dart';
import '../shared/functions.dart';
import '../shared/settings.dart';

abstract class Observer<T> implements Disposable {
  /// An observer with custom handlers.
  factory Observer({
    NextCallback<T> next,
    ErrorCallback error,
    CompleteCallback complete,
  }) =>
      BaseObserver<T>(next ?? nullFunction1, error ?? defaultErrorHandler,
          complete ?? nullFunction0);

  /// An observer that is only interested in values.
  factory Observer.next(NextCallback<T> next, {bool ignoreErrors = false}) =>
      BaseObserver<T>(
          next,
          ignoreErrors ? nullFunction1Optional1 : defaultErrorHandler,
          nullFunction0);

  /// An observer that is only interested in failure.
  factory Observer.error(ErrorCallback error) =>
      BaseObserver<T>(nullFunction1, error, nullFunction0);

  /// An observer that is only interested in success.
  factory Observer.complete(CompleteCallback complete,
          {bool ignoreErrors = false}) =>
      BaseObserver<T>(
          nullFunction1,
          ignoreErrors ? nullFunction1Optional1 : defaultErrorHandler,
          complete);

  /// Pass a value to the observer.
  void next(T value);

  /// Pass an error to the observer.
  void error(Object error, [StackTrace stackTrace]);

  /// Pass completion to the observer.
  void complete();
}
