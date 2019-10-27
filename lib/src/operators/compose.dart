library rx.operators.compose;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/subscriber.dart';

/// Operator function for lifting into an Observable.
typedef Operator<R, T> = Subscriber<R> Function(Subscriber<T>);

/// Function that receives an [Observable] and returns another one, possibly
/// changing its type.
typedef Transformer<T, R> = Observable<R> Function(Observable<T>);

extension ConcatOperator<T> on Observable<T> {
  /// Prepends the emission of items with [transformation].
  Observable<R> compose<R>(Transformer<T, R> transformation) =>
      transformation(this);
}
