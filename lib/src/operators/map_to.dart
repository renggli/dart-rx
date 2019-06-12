library rx.operators.map_to;

import 'package:rx/core.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';

/// Emits the given constant value on the output Observable every time the
/// source Observable emits a value.
Operator<T, S> mapTo<T, S>(S constant) => (subscriber, source) =>
    source.subscribe(_MapToSubscriber(subscriber, constant));

class _MapToSubscriber<T, S> extends Subscriber<T> {
  final S constant;

  _MapToSubscriber(Observer<S> destination, this.constant) : super(destination);

  @override
  void onNext(T value) => doNext(constant);
}
