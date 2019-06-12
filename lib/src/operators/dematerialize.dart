library rx.operators.dematerialize;

import 'package:rx/src/core/notifications.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

Operator<Notification<T>, T> dematerialize<T>() => (source, destination) =>
    source.subscribe(_DematerializeSubscriber<T>(destination));

class _DematerializeSubscriber<T> extends Subscriber<Notification<T>> {
  _DematerializeSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(Notification<T> value) {
    if (value is NextNotification<T>) {
      doNext(value.value);
    } else if (value is ErrorNotification<T>) {
      doError(value.error, value.stackTrace);
    } else if (value is CompleteNotification<T>) {
      doComplete();
    }
  }
}
