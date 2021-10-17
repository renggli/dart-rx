import '../core/errors.dart';
import '../disposables/action.dart';
import '../disposables/disposable.dart';
import '../schedulers/settings.dart';
import 'functions.dart';

void _standardErrorHandler(Object error, StackTrace stackTrace) =>
    defaultScheduler.schedule(() => throw UnhandledError(error, stackTrace));

/// The current system error handler.
ErrorCallback? _defaultErrorHandler;

/// Returns the current system error handler.
ErrorCallback get defaultErrorHandler =>
    _defaultErrorHandler ?? _standardErrorHandler;

/// Sets the default error handler.
set defaultErrorHandler(ErrorCallback? errorHandler) =>
    _defaultErrorHandler = errorHandler;

/// Replaces the default error handler.
Disposable replaceErrorHandler(ErrorCallback? errorHandler) {
  final originalErrorHandler = _defaultErrorHandler;
  _defaultErrorHandler = errorHandler;
  return ActionDisposable(() => _defaultErrorHandler = originalErrorHandler);
}
