library rx.constructors.concat;

import 'package:rx/src/converters/iterable_to_observable.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/operators/merge.dart';

/// Subscribe to the list of [Observable] in order, and when the previous one
/// complete then subscribe to the next one.
Observable<T> concat<T>(Iterable<Observable<T>> observables,
        {Scheduler scheduler}) =>
    observables
        .toObservable(scheduler: scheduler)
        .mergeMap((observable) => observable, concurrent: 1);
