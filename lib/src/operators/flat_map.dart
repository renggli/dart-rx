import 'package:more/functional.dart';

import '../core/observable.dart';
import '../shared/constants.dart';
import 'merge.dart';

extension FlattenObservable<T> on Observable<Observable<T>> {
  /// For each observable of this [Observable], subscribe to at most
  /// `concurrent` observables and emit all values.
  Observable<T> flatten({int concurrent = maxInteger}) =>
      mergeAll(concurrent: concurrent);
}

extension FlatMapOperator<T> on Observable<T> {
  /// For each value of this [Observable], merge all values from the single
  /// higher-order `observable`. Subscribe to at most `concurrent` sources.
  Observable<R> flatMapTo<R>(Observable<R> observable,
          {int concurrent = maxInteger}) =>
      mergeMapTo<R>(observable, concurrent: concurrent);

  /// For each value of this [Observable], transform that value to a
  /// higher-order observable with the provided `project` function and merge
  /// its emitted values. Subscribe to at most `concurrent` sources.
  Observable<R> flatMap<R>(Map1<T, Observable<R>> project,
          {int concurrent = maxInteger}) =>
      mergeMap<R>(project, concurrent: concurrent);
}
