library rx.operators.concat;

import '../constructors/concat.dart';
import '../constructors/from.dart';
import '../core/observable.dart';

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
