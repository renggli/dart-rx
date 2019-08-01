library rx.operators.is_empty;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Emits `false` if the input observable emits any values, or emits `true` if
/// the input observable completes without emitting any values.
OperatorFunction<T, bool> isEmpty<T>() =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_IsEmptySubscriber<T>(subscriber)));

class _IsEmptySubscriber<T> extends Subscriber<T> {
  _IsEmptySubscriber(Observer<bool> destination) : super(destination);

  @override
  void onNext(T value) {
    doNext(false);
    doComplete();
  }

  @override
  void onComplete() {
    doNext(true);
    doComplete();
  }
}
