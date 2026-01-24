import '../core/observable.dart';

/// Function that receives an [Observable] and returns another one, possibly
/// changing its type.
typedef Transformer<T, R> = Observable<R> Function(Observable<T> source);

extension ComposeOperator<T> on Observable<T> {
  /// Prepends the emission of items with [transformation].
  ///
  /// For example:
  ///
  /// ```dart
  /// just(1)
  ///   .compose((source) => source.map((i) => i + 1))
  ///   .subscribe(Observer(next: print)); // prints 2
  /// ```
  Observable<R> compose<R>(Transformer<T, R> transformation) =>
      transformation(this);
}
