library rx.operators.map_to;

import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscription.dart';

/// Emits the given constant value on the output Observable every time the
/// source Observable emits a value.
Operator<T, S> mapTo<T, S>(S constant) => _MapToOperator(constant);

class _MapToOperator<T, S> implements Operator<T, S> {
  final S constant;

  _MapToOperator(this.constant);

  @override
  Subscription call(Observable<T> source, Observer<S> destination) =>
      source.subscribe(_MapToSubscriber(destination, constant));
}

class _MapToSubscriber<T, S> extends Subscriber<T> {
  final S constant;

  _MapToSubscriber(Observer<S> destination, this.constant) : super(destination);

  @override
  void onNext(T value) => destination.next(constant);
}
