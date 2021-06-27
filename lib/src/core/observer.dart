import 'package:more/functional.dart';

import '../disposables/disposable.dart';
import '../observers/base.dart';
import '../shared/functions.dart';
import '../shared/settings.dart';

abstract class Observer<T> implements Disposable {
  /// An observer with custom handlers:
  ///
  /// - [next] is a callback that is called zero or more times with values
  ///   of type [T].
  /// - [error] is a callback that is called when the observer terminates
  ///   with an exception and an optional stack trace. If you do not provide an
  ///   this callback the error is passed to the [defaultErrorHandler], unless
  ///   [ignoreErrors] is set to `true`.
  /// - [complete] is a callback that is called when the observer successfully
  ///   terminates.
  factory Observer({
    NextCallback<T>? next,
    ErrorCallback? error,
    CompleteCallback? complete,
    bool ignoreErrors = false,
  }) =>
      BaseObserver<T>(
          next ?? emptyFunction1,
          error ?? (ignoreErrors ? emptyFunction2 : defaultErrorHandler),
          complete ?? emptyFunction0);

  /// An observer that is only interested in values.
  ///
  /// By default errors are passed to the [defaultErrorHandler], unless
  /// [ignoreErrors] is set to `true`.
  factory Observer.next(NextCallback<T> next, {bool ignoreErrors = false}) =>
      BaseObserver<T>(next, ignoreErrors ? emptyFunction2 : defaultErrorHandler,
          emptyFunction0);

  /// An observer that is only interested in errors.
  factory Observer.error(ErrorCallback error) =>
      BaseObserver<T>(emptyFunction1, error, emptyFunction0);

  /// An observer that is only interested in completions.
  ///
  /// By default all errors are passed to the [defaultErrorHandler], unless
  /// [ignoreErrors] is set to `true`.
  factory Observer.complete(CompleteCallback complete,
          {bool ignoreErrors = false}) =>
      BaseObserver<T>(emptyFunction1,
          ignoreErrors ? emptyFunction2 : defaultErrorHandler, complete);

  /// Pass a value to the observer.
  void next(T value);

  /// Pass an error to the observer.
  void error(Object error, StackTrace stackTrace);

  /// Pass completion to the observer.
  void complete();
}
