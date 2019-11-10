library rx.constructors.merge;

import '../converters/iterable_to_observable.dart';
import '../core/observable.dart';
import '../operators/merge.dart';
import '../shared/functions.dart';

/// Creates an [Observable] which concurrently emits all values from every
/// source [Observable].
Observable<T> merge<T>(Iterable<Observable<T>> observables) =>
    observables.toObservable().mergeMap(identityFunction);
