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
  Subject<bool> get isDisposed => has('isDisposed', (d) => d.isDisposed);
}

/// Extension on [Subject] of [Event].
extension EventChecks<T> on Subject<Event<T>> {
  Subject<bool> get isNext => has('isNext', (e) => e.isNext);
  Subject<bool> get isError => has('isError', (e) => e.isError);
  Subject<bool> get isComplete => has('isComplete', (e) => e.isComplete);
  Subject<T> get value => has('value', (e) => e.value);
  Subject<Object> get error => has('error', (e) => e.error);
  Subject<StackTrace> get stackTrace => has('stackTrace', (e) => e.stackTrace);
}

/// Extension on [Subject] of [UnhandledError].
extension UnhandledErrorChecks on Subject<UnhandledError> {
  Subject<Object> get error => has('error', (u) => u.error);
  Subject<StackTrace> get stackTrace => has('stackTrace', (u) => u.stackTrace);
}
