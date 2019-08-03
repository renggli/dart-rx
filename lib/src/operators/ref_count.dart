library rx.operators.ref_count;

import 'package:rx/observables.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/observables/ref_counted.dart';

/// Connects to the source only if there is more than one subscriber.
OperatorFunction<T, T> refCount<T>() =>
    (source) => RefCountedObservable<T>(source);
