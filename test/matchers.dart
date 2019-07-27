library rx.test.matchers;

import 'package:matcher/matcher.dart';
import 'package:rx/src/core/errors.dart';
import 'package:test/test.dart';

/// Matches the throwing of a [TooFewError].
final Matcher throwsTooFewError = throwsA(const TypeMatcher<TooFewError>());

/// Matches the throwing of a [TooManyError].
final Matcher throwsTooManyError = throwsA(const TypeMatcher<TooManyError>());

/// Matches the throwing of a [TimeoutError].
final Matcher throwsTimeoutError = throwsA(const TypeMatcher<TimeoutError>());

/// Matches the throwing of an [UnsubscribedError].
final Matcher throwsUnsubscribedError =
    throwsA(const TypeMatcher<UnsubscribedError>());

/// Matches the throwing of an [UnsubscriptionError].
final Matcher throwsUnsubscriptionError =
    throwsA(const TypeMatcher<UnsubscriptionError>());
