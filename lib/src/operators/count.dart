library rx.operators.count;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Counts the number of emissions and emits that number on completion.
Operator<T, int> count<T>() =>
    (source, destination) => source.subscribe(_CountSubscriber(destination));

class _CountSubscriber<T> extends Subscriber<T> {
  int count = 0;

  _CountSubscriber(Observer<int> destination) : super(destination);

  @override
  void onNext(T value) {
    count++;
  }

  @override
  void onComplete() {
    doNext(count);
    doComplete();
  }
}
