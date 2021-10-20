import 'package:rx/core.dart';
import 'package:rx/disposables.dart';
import 'package:test/test.dart';

/// Matches the throwing of a [TooFewError].
final Matcher throwsTooFewError = throwsA(isA<TooFewError>());

/// Matches the throwing of a [TooManyError].
final Matcher throwsTooManyError = throwsA(isA<TooManyError>());

/// Matches the throwing of a [TimeoutError].
final Matcher throwsTimeoutError = throwsA(isA<TimeoutError>());

/// Matches the throwing of an [DisposedError].
final Matcher throwsDisposedError = throwsA(isA<DisposedError>());

/// Matches the throwing of an [DisposeError].
final Matcher throwsDisposeError = throwsA(isA<DisposeError>());

/// Matches the throwing of a [UnhandledError].
final Matcher throwsUnhandledError = throwsA(isA<UnhandledError>());

/// Observer that fails all calls.
Observer<T> createFailingObserver<T>() => Observer<T>(
      next: (value) => fail('Unepxected next: $value.'),
      error: (error, stackTrace) => fail('Unepxected error: $error.'),
      complete: () => fail('Unexpected complete.'),
    );
