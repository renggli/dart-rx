library rx.test.matchers;

import 'package:matcher/matcher.dart';
import 'package:rx/disposables.dart';
import 'package:rx/src/core/errors.dart';
import 'package:test/test.dart';

/// Matches the throwing of a [TooFewError].
final Matcher throwsTooFewError = throwsA(const TypeMatcher<TooFewError>());

/// Matches the throwing of a [TooManyError].
final Matcher throwsTooManyError = throwsA(const TypeMatcher<TooManyError>());

/// Matches the throwing of a [TimeoutError].
final Matcher throwsTimeoutError = throwsA(const TypeMatcher<TimeoutError>());

/// Matches the throwing of an [DisposedError].
final Matcher throwsUnsubscribedError =
    throwsA(const TypeMatcher<DisposedError>());

/// Matches the throwing of an [DisposeError].
final Matcher throwsUnsubscriptionError =
    throwsA(const TypeMatcher<DisposeError>());
