import '../converters/iterable_to_observable.dart';
import '../core/observable.dart';
import '../operators/merge.dart';
import '../shared/constants.dart';

/// Creates an [Observable] which concurrently emits all values from every
/// source [Observable].
Observable<T> merge<T>(Iterable<Observable<T>> observables,
        {int concurrent = maxInteger}) =>
    observables.toObservable().mergeAll(concurrent: concurrent);
