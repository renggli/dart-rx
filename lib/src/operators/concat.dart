library rx.operators.concat;

import 'package:rx/src/constructors/concat.dart';
import 'package:rx/src/constructors/from.dart';
import 'package:rx/src/core/observable.dart';

extension ConcatOperator<T> on Observable<T> {
  /// Prepends the emission of items with [object].
  Observable<T> beginWith(
          /** void|Observable<T>|Iterable<T>|Future<T>|Stream<T>|T */
          Object object) =>
      concat<T>([from<T>(object), this]);

  /// Appends the emission of items with [object].
  Observable<T> endWith(
          /** void|Observable<T>|Iterable<T>|Future<T>|Stream<T>|T */
          Object object) =>
      concat<T>([this, from<T>(object)]);
}
