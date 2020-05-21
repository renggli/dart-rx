library rx.shared.settings;

import '../core/errors.dart';
import '../disposables/action.dart';
import '../disposables/disposable.dart';
import '../schedulers/settings.dart';
import 'functions.dart';

// ignore: prefer_function_declarations_over_variables
ErrorCallback _defaultErrorHandler = (error, [stackTrace]) =>
    defaultScheduler.schedule(() => throw UnhandledError(error, stackTrace));

/// Returns the current system error handler.
ErrorCallback get defaultErrorHandler => _defaultErrorHandler;

/// Sets the default error handler.
set defaultErrorHandler(ErrorCallback errorHandler) =>
    _defaultErrorHandler = errorHandler;

/// Replaces the default error handler.
Disposable replaceErrorHandler(ErrorCallback errorHandler) {
  final originalErrorHandler = _defaultErrorHandler;
  _defaultErrorHandler = errorHandler;
  return ActionDisposable(() => _defaultErrorHandler = originalErrorHandler);
}
