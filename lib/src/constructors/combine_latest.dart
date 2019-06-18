library rx.operators.combine_latest;

import 'package:rx/schedulers.dart';
import 'package:rx/src/constructors/iterable.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/operators/combine_latest.dart' as operators;

/// Combines a list of [Observable] to an [Observable] whose values are
/// calculated from the latest values of each of its inputs.
Observable<List<T>> combineLatest<T>(Iterable<Observable<T>> iterable,
        {Scheduler scheduler}) =>
    fromIterable(iterable, scheduler: scheduler ?? ImmediateScheduler())
        .lift(operators.combineLatest());
