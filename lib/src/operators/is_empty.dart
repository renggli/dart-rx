library rx.operators.is_empty;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Emits `false` if the input observable emits any values, or emits `true` if
/// the input observable completes without emitting any values.
Operator<T, bool> isEmpty<T>() => _IsEmptyOperator<T>();

class _IsEmptyOperator<T> implements Operator<T, bool> {
  _IsEmptyOperator();

  @override
  Subscription call(Observable<T> source, Observer<bool> destination) =>
      source.subscribe(_IsEmptySubscriber(destination));
}

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
