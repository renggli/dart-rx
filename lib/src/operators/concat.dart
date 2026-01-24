import '../constructors/concat.dart';
import '../core/observable.dart';

extension ConcatOperator<T> on Observable<T> {
  /// Prepends the emission of items with an [Observable].
  ///
  /// For example:
  ///
  /// ```dart
  /// just(2).beginWith(just(1)).subscribe(Observer(next: print)); // prints 1, 2
  /// ```
  Observable<T> beginWith(Observable<T> observable) =>
      concat<T>([observable, this]);

  /// Appends the emission of items with an [Observable].
  ///
  /// For example:
  ///
  /// ```dart
  /// just(1).endWith(just(2)).subscribe(Observer(next: print)); // prints 1, 2
  /// ```
  Observable<T> endWith(Observable<T> observable) =>
      concat<T>([this, observable]);
}
