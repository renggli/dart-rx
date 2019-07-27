library rx.constructors.concat;

import 'package:rx/src/constructors/iterable.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/operators/merge.dart';

import 'iterable.dart';

/// Subscribe to the list of [Observable] in order, and when the previous one
/// complete then subscribe to the next one.
Observable<T> concat<T>(Iterable<Observable<T>> observables) =>
    fromIterable(observables)
        .lift(mergeMap((observable) => observable, concurrent: 1));
