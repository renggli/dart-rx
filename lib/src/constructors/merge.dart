library rx.constructors.merge;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/operators/merge_map.dart';

import 'iterable.dart';

/// Creates an [Observable] which concurrently emits all values from every
/// source [Observable].
Observable<T> merge<T>(Iterable<Observable<T>> observables) =>
    fromIterable(observables).lift(mergeMap((observable) => observable));
