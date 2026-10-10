import 'package:checks/checks.dart';
import 'package:rx/core.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/shared.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

void main() {
  group('error handler', () {
    final error = ArgumentError('Custom error');
    final stackTrace = StackTrace.current;
    tearDown(() => defaultErrorHandler = null);
    tearDown(() => defaultScheduler = null);
    test('default', () {
      // The default error handler asynchronously triggers the error.
      replaceDefaultScheduler(const ImmediateScheduler());
      final observer = Observer<int>();
      check(() => observer.error(error, stackTrace)).throws<UnhandledError>()
        ..error.equals(error)
        ..stackTrace.equals(stackTrace)
        ..has((v) => v.toString(), 'toString').startsWith('UnhandledError');
    });
    test('custom', () {
      Object? observedError;
      StackTrace? observedStackTrace;
      void customErrorHandler(Object error, StackTrace stackTrace) {
        observedError = error;
        observedStackTrace = stackTrace;
        throw error;
      }

      check(defaultErrorHandler).not((it) => it.equals(customErrorHandler));
      defaultErrorHandler = customErrorHandler;
      check(defaultErrorHandler).equals(customErrorHandler);
      final observer = Observer<int>();
      check(() => observer.error(error, stackTrace)).throws<ArgumentError>();
      check(observedError).equals(error);
      check(observedStackTrace).equals(stackTrace);
    });
    test('replace', () {
      void customErrorHandler(Object error, StackTrace stackTrace) =>
          throw error;
      check(defaultErrorHandler).not((it) => it.equals(customErrorHandler));
      final subscription = replaceErrorHandler(customErrorHandler);
      check(defaultErrorHandler).equals(customErrorHandler);
      subscription.dispose();
      check(defaultErrorHandler).not((it) => it.equals(customErrorHandler));
    });
  });
}
