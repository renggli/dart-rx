import 'package:checks/checks.dart';
import 'package:checks/context.dart' hide Context;
import 'package:matcher/matcher.dart' show Matcher, StringDescription;
import 'package:rx/core.dart';
import 'package:rx/disposables.dart';
import 'package:rx/events.dart';
import 'package:test/scaffolding.dart' show TestFailure;

/// Observer that fails all calls.
Observer<T> createFailingObserver<T>() => Observer<T>(
  next: (value) => fail('Unexpected next: $value.'),
  error: (error, stackTrace) => fail('Unexpected error: $error.'),
  complete: () => fail('Unexpected complete.'),
);

/// Throws a test failure.
Never fail(String message) => throw TestFailure(message);

/// Extension on [Subject] of [Function] providing error checks for rx errors.
extension FunctionRxChecks on Subject<void Function()> {
  void throwsTooFewError() => throws<TooFewError>();
  void throwsTooManyError() => throws<TooManyError>();
  void throwsTimeoutError() => throws<TimeoutError>();
  void throwsDisposedError() => throws<DisposedError>();
  void throwsDisposeError() => throws<DisposeError>();
  void throwsUnhandledError() => throws<UnhandledError>();
}

/// Extension on [Subject] allowing [Matcher] assertions.
extension MatcherChecks<T> on Subject<T> {
  void matches(Matcher matcher) {
    context.expect(() => [matcher.describe(StringDescription()).toString()], (
      actual,
    ) {
      final matchState = <Object?, Object?>{};
      if (matcher.matches(actual, matchState)) return null;
      final description = StringDescription();
      matcher.describeMismatch(actual, description, matchState, false);
      final mismatch = description.toString();
      return Rejection(
        which: mismatch.isEmpty ? ['did not match $matcher'] : [mismatch],
      );
    });
  }
}

/// Extension on [Subject] of [Disposable].
extension DisposableChecks on Subject<Disposable> {
  Subject<bool> get isDisposed => has((d) => d.isDisposed, 'isDisposed');
}

/// Extension on [Subject] of [Event].
extension EventChecks<T> on Subject<Event<T>> {
  Subject<bool> get isNext => has((e) => e.isNext, 'isNext');
  Subject<bool> get isError => has((e) => e.isError, 'isError');
  Subject<bool> get isComplete => has((e) => e.isComplete, 'isComplete');
  Subject<T> get value => has((e) => e.value, 'value');
  Subject<Object> get error => has((e) => e.error, 'error');
  Subject<StackTrace> get stackTrace => has((e) => e.stackTrace, 'stackTrace');
}

/// Extension on [Subject] of [UnhandledError].
extension UnhandledErrorChecks on Subject<UnhandledError> {
  Subject<Object> get error => has((u) => u.error, 'error');
  Subject<StackTrace> get stackTrace => has((u) => u.stackTrace, 'stackTrace');
}
