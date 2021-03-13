import '../constructors/concat.dart';
import '../core/observable.dart';

extension ConcatOperator<T> on Observable<T> {
  /// Prepends the emission of items with an [Observable].
  Observable<T> beginWith(Observable<T> observable) =>
      concat<T>([observable, this]);

  /// Appends the emission of items with an [Observable].
  Observable<T> endWith(Observable<T> observable) =>
      concat<T>([this, observable]);
}
