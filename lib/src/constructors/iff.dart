library rx.constructors.iff;

import '../core/observable.dart';
import '../shared/functions.dart';
import 'defer.dart';
import 'empty.dart';

/// Decides at subscription time which [Observable] will actually be
/// subscribed to.
Observable<T> iff<T>(Predicate0 condition,
        [Observable<T>? trueBranch, Observable<T>? falseBranch]) =>
    defer(() =>
        condition() ? trueBranch ?? empty<T>() : falseBranch ?? empty<T>());
