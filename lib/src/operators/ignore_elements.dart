library rx.operators.ignore_elements;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

/// Ignores all items emitted by the source and only passes calls to
/// `complete` or `error`.
Operator<T, T> ignoreElements<T>() => _IgnoreElementsOperator();

class _IgnoreElementsOperator<T> implements Operator<T, T> {
  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_IgnoreElementsSubscriber(destination));
}

class _IgnoreElementsSubscriber<T> extends Subscriber<T> {
  _IgnoreElementsSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(T value) {}
}
