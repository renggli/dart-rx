library rx.operators.flat_map;

import '../core/observable.dart';
import '../shared/constants.dart';
import '../shared/functions.dart';
import 'merge.dart';

extension FlatMapOperator<T> on Observable<T> {
  /// Emits all merged values from a single higher-order `observable. Subscribes
  /// to at most `concurrent` sources.
  Observable<R> flatMapTo<R>(Observable<R> observable,
          {int concurrent = maxInteger}) =>
      mergeMapTo<R>(observable, concurrent: concurrent);

  /// Emits all merged values from a higher-order [Observable] retrieved by
  /// projecting the values of the source to higher-order [Observable]s.
  /// Subscribes to at most `concurrent` sources.
  Observable<R> flatMap<R>(Map1<T, Observable<R>> project,
          {int concurrent = maxInteger}) =>
      mergeMap<R>(project, concurrent: concurrent);
}
