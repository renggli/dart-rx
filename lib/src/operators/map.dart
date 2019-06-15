library rx.operators.map;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef MapTransform<T, S> = S Function(T value);

/// Applies a given project function to each value emitted by the source
/// Observable, and emits the resulting values as an Observable.
Operator<T, S> map<T, S>(MapTransform<T, S> transform) =>
    (subscriber, source) =>
        source.subscribe(_MapSubscriber(subscriber, transform));

/// Emits the given constant value on the output Observable every time the
/// source Observable emits a value.
Operator<T, S> mapTo<T, S>(S constant) => (subscriber, source) =>
    source.subscribe(_MapSubscriber(subscriber, (_) => constant));

class _MapSubscriber<T, S> extends Subscriber<T> {
  final MapTransform<T, S> transform;

  _MapSubscriber(Observer<S> destination, this.transform) : super(destination);

  @override
  void onNext(T value) {
    final transformEvent = Event.map1(transform, value);
    if (transformEvent is ErrorEvent) {
      doError(transformEvent.error, transformEvent.stackTrace);
    } else {
      doNext(transformEvent.value);
    }
  }
}
