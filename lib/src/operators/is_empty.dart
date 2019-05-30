library rx.operators.is_empty;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Emits `false` if the input observable emits any values, or emits `true` if
/// the input observable completes without emitting any values.
Operator<T, bool> isEmpty<T>() => _IsEmptyOperator();

class _IsEmptyOperator<T> implements Operator<T, T> {
  _IsEmptyOperator();

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_IsEmptySubscriber(destination));
}

class _IsEmptySubscriber<T> extends Subscriber<T> {
  _IsEmptySubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(T value) {
    destination.next(false);
    destination.complete();
    unsubscribe();
  }

  @override
  void onComplete() {
    destination.next(true);
    destination.complete();
    unsubscribe();
  }
}
