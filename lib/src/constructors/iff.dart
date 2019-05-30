library rx.constructors.iff;

import 'package:rx/src/constructors/defer.dart';
import 'package:rx/src/core/observable.dart';

typedef Condition = bool Function();

/// Decides at subscription time which [Observable] will actually be subscribed.
Observable<T> iff<T>(Condition condition,
        {Observable<T> trueBranch, Observable<T> falseBranch}) =>
    defer(() => condition() ? trueBranch : falseBranch);
