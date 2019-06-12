library rx.operators.materialize;

import 'package:rx/src/core/notifications.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

Operator<T, Notification<T>> materialize<T>() => (source, destination) =>
    source.subscribe(_MaterializeSubscriber<T>(destination));

class _MaterializeSubscriber<T> extends Subscriber<T> {
  _MaterializeSubscriber(Observer<Notification<T>> destination)
      : super(destination);

  @override
  void onNext(T value) => doNext(NextNotification<T>(value));

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    doNext(ErrorNotification<T>(error, stackTrace));
    doComplete();
  }

  @override
  void onComplete() {
    doNext(CompleteNotification<T>());
    doComplete();
  }
}
