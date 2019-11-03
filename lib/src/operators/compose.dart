library rx.operators.compose;

import 'package:rx/src/core/observable.dart';

/// Function that receives an [Observable] and returns another one, possibly
/// changing its type.
typedef Transformer<T, R> = Observable<R> Function(Observable<T>);

extension ComposeOperator<T> on Observable<T> {
  /// Prepends the emission of items with [transformation].
  Observable<R> compose<R>(Transformer<T, R> transformation) =>
      transformation(this);
}
