library rx.operators.filter;

import 'package:rx/core.dart';
import 'package:rx/src/core/notifications.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef FilterFunction<T> = bool Function(T value);

/// Filter items emitted by the source Observable by only emitting those that
/// satisfy a specified predicate.
Operator<T, T> filter<T>(FilterFunction filterFunction) =>
    (subscriber, source) =>
        source.subscribe(_FilterSubscriber(subscriber, filterFunction));

class _FilterSubscriber<T> extends Subscriber<T> {
  final FilterFunction<T> filterFunction;

  _FilterSubscriber(Observer<T> destination, this.filterFunction)
      : super(destination);

  @override
  void onNext(T value) {
    final notification = Notification.map(value, filterFunction);
    if (notification is ErrorNotification) {
      doError(notification.error, notification.stackTrace);
    } else if (notification.value) {
      doNext(value);
    }
  }
}
