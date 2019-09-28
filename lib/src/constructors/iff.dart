library rx.constructors.iff;

import 'package:rx/src/constructors/defer.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/shared/functions.dart';

extension IffConstructor on Observable {
  /// Decides at subscription time which [Observable] will actually be
  /// subscribed to.
  static Observable<T> iff<T>(Predicate0 condition,
          [Observable<T> trueBranch, Observable<T> falseBranch]) =>
      defer(() => condition() ? trueBranch : falseBranch);
}
