library rx.constructors.concat;

import '../converters/iterable_to_observable.dart';
import '../core/observable.dart';
import '../operators/merge.dart';
import '../schedulers/scheduler.dart';

/// Subscribe to the list of [Observable] in order, and when the previous one
/// complete then subscribe to the next one.
Observable<T> concat<T>(Iterable<Observable<T>> observables,
        {Scheduler? scheduler}) =>
    observables
        .toObservable(scheduler: scheduler)
        .mergeMap((observable) => observable, concurrent: 1);
