library rx.operators.map;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Applies a given project function to each value emitted by the source
/// Observable, and emits the resulting values as an Observable.
OperatorFunction<T, R> map<T, R>(Map1<T, R> transform) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_MapSubscriber<T, R>(subscriber, transform)));

/// Emits the given constant value on the output Observable every time the
/// source Observable emits a value.
OperatorFunction<Object, R> mapTo<R>(R value) =>
    map<Object, R>(constantFunction1(value));

class _MapSubscriber<T, R> extends Subscriber<T> {
  final Map1<T, R> transform;

  _MapSubscriber(Observer<R> destination, this.transform) : super(destination);

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
