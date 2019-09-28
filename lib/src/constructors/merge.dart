library rx.constructors.merge;

import 'package:rx/src/constructors/iterable.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/operators/merge.dart';
import 'package:rx/src/shared/functions.dart';

extension MergeConstructor on Observable {
  /// Creates an [Observable] which concurrently emits all values from every
  /// source [Observable].
  Observable<T> merge<T>(Iterable<Observable<T>> observables) =>
      observables.toObservable().mergeMap(identityFunction);
}
