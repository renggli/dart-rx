library rx.operators.count;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Counts the number of emissions and emits that number on completion.
Map1<Observable<T>, Observable<int>> count<T>() => (source) => source.lift(
    (source, subscriber) => source.subscribe(_CountSubscriber<T>(subscriber)));

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
