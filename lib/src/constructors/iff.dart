import 'package:more/functional.dart';

import '../core/observable.dart';
import 'defer.dart';
import 'empty.dart';

/// Decides at subscription time which [Observable] will actually be
/// subscribed to.
///
/// For example:
///
/// ```dart
/// iff(
///   () => true,
///   just('a'),
///   just('b'),
/// ).subscribe(Observer(next: print)); // prints 'a'
/// ```
Observable<T> iff<T>(
  Predicate0 condition, [
  Observable<T>? trueBranch,
  Observable<T>? falseBranch,
]) => defer(() => condition() ? trueBranch ?? empty() : falseBranch ?? empty());
