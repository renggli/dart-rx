library rx.operators.map;

import 'package:rx/src/core/notifications.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef MapFunction<T, S> = S Function(T value);

/// Applies a given project function to each value emitted by the source
/// Observable, and emits the resulting values as an Observable.
Operator<T, S> map<T, S>(MapFunction<T, S> mapFunction) =>
    (subscriber, source) =>
        source.subscribe(_MapSubscriber(subscriber, mapFunction));

class _MapSubscriber<T, S> extends Subscriber<T> {
  final MapFunction<T, S> mapFunction;

  _MapSubscriber(Observer<S> destination, this.mapFunction)
      : super(destination);

  @override
  void onNext(T value) {
    final notification = Notification.map(value, mapFunction);
    if (notification is ErrorNotification) {
      doError(notification.error, notification.stackTrace);
    } else {
      doNext(notification.value);
    }
  }
}
