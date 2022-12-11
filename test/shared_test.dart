import 'package:rx/core.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/shared.dart';
import 'package:test/test.dart';

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
      expect(
          () => observer.error(error, stackTrace),
          throwsA(isA<UnhandledError>()
              .having((value) => value.error, 'error', error)
              .having((value) => value.stackTrace, 'stackTrace', stackTrace)
              .having((value) => value.toString(), 'toString',
                  startsWith('UnhandledError'))));
    });
    test('custom', () {
      Object? observedError;
      StackTrace? observedStackTrace;
      void customErrorHandler(Object error, StackTrace stackTrace) {
        observedError = error;
        observedStackTrace = stackTrace;
        throw error;
      }

      expect(defaultErrorHandler, isNot(customErrorHandler));
      defaultErrorHandler = customErrorHandler;
      expect(defaultErrorHandler, customErrorHandler);
      final observer = Observer<int>();
      expect(() => observer.error(error, stackTrace), throwsArgumentError);
      expect(observedError, error);
      expect(observedStackTrace, stackTrace);
    });
    test('replace', () {
      void customErrorHandler(Object error, StackTrace stackTrace) =>
          throw error;
      expect(defaultErrorHandler, isNot(customErrorHandler));
      final subscription = replaceErrorHandler(customErrorHandler);
      expect(defaultErrorHandler, customErrorHandler);
      subscription.dispose();
      expect(defaultErrorHandler, isNot(customErrorHandler));
    });
  });
}
