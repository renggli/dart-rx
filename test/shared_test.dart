import 'package:rx/shared.dart';
import 'package:rx/core.dart';
import 'package:rx/schedulers.dart';
import 'package:test/test.dart';

void main() {
  group('error handler', () {
    final error = ArgumentError('Custom error');
    final stackTrace = StackTrace.current;
    tearDown(() => defaultErrorHandler = null);
    tearDown(() => defaultScheduler = null);
    test('default', () {
      replaceDefaultScheduler(ImmediateScheduler());
      final observer = Observer();
      expect(
          () => observer.error(error, stackTrace),
          throwsA(isA<UnhandledError>()
              .having((value) => value.error, 'error', error)
              .having((value) => value.stackTrace, 'stackTrace', stackTrace)));
    });
    test('custom', () {
      Object? observedError;
      StackTrace? observedStackTrace;
      replaceErrorHandler((error, stackTrace) {
        observedError = error;
        observedStackTrace = stackTrace;
        throw error;
      });
      final observer = Observer();
      expect(() => observer.error(error, stackTrace), throwsArgumentError);
      expect(observedError, error);
      expect(observedStackTrace, stackTrace);
    });
  });
}
