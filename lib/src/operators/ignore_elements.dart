library rx.operators.ignore_elements;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Ignores all items emitted by the source and only passes calls to
/// `complete` or `error`.
Operator<T, T> ignoreElements<T>() => (source, destination) =>
    source.subscribe(_IgnoreElementsSubscriber(destination));

class _IgnoreElementsSubscriber<T> extends Subscriber<T> {
  _IgnoreElementsSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(T value) {}
}
