library rx.operators.combine_latest;

import '../converters/iterable_to_observable.dart';
import '../core/observable.dart';
import '../core/scheduler.dart';
import '../operators/combine_latest.dart';

/// Combines a list of [Observable] to an [Observable] whose values are
/// calculated from the latest values of each of its inputs.
Observable<List<T>> combineLatest<T>(Iterable<Observable<T>> iterable,
        {Scheduler scheduler}) =>
    iterable.toObservable(scheduler: scheduler).combineLatest();
