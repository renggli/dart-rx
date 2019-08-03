library rx.operators.ref_count;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/observables/ref_counted.dart';
import 'package:rx/src/shared/functions.dart';

/// Connects to the source only if there is more than one subscriber.
Map1<Observable<T>, RefCountedObservable<T>> refCount<T>() =>
    (source) => RefCountedObservable<T>(source);
