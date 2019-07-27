library rx.operators.zip;

import 'package:rx/src/constructors/iterable.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/operators/zip.dart' as operators;
import 'package:rx/src/schedulers/immediate.dart';

/// Combines a list of [Observable] to an [Observable] whose values are
/// calculated from the next value of each of its inputs.
Observable<List<T>> zip<T>(Iterable<Observable<T>> iterable,
        {Scheduler scheduler}) =>
    fromIterable(iterable, scheduler: scheduler ?? ImmediateScheduler())
        .lift(operators.zip());
