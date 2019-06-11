library rx.operators.merge_map_to;

import 'package:rx/src/core/constants.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/operator.dart';

import 'merge_map.dart';

/// Projects each source value to the same [Observable] which is merged multiple
/// times in the output [Observable].
Operator<T, R> mergeMapTo<T, R>(Observable<R> observable,
        {int concurrent = maxInteger}) =>
    mergeMap((_) => observable, concurrent: concurrent);
