library rx.operators.first;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Returns the first element of an observable sequence.
Operator<T, T> first<T>() =>
    (subscriber, source) => source.subscribe(_FirstSubscriber(subscriber));

class _FirstSubscriber<T> extends Subscriber<T> {
  _FirstSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(T value) {
    doNext(value);
    doComplete();
  }

  @override
  void onComplete() {
    doError('Sequence contains no elements');
  }
}
