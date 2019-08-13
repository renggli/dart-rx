library rx.operators.cast;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Casts all values from a source observable to [R].
OperatorFunction<T, R> cast<T, R>() =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_CastSubscriber<T, R>(subscriber)));

class _CastSubscriber<T, R> extends Subscriber<T> {
  _CastSubscriber(Observer<R> destination) : super(destination);

  @override
  void onNext(T value) {
    doNext(value as R);
  }
}
