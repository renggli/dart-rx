import '../converters/iterable_to_observable.dart';
import '../core/observable.dart';
import '../operators/zip.dart';
import '../schedulers/immediate.dart';
import '../schedulers/scheduler.dart';

/// Combines a list of [Observable] to an [Observable] whose values are
/// calculated from the next value of each of its inputs.
Observable<List<T>> zip<T>(Iterable<Observable<T>> iterable,
        {Scheduler? scheduler}) =>
    iterable
        .toObservable(scheduler: scheduler ?? const ImmediateScheduler())
        .zip();
