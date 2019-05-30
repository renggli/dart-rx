library rx.operators.materialize;

import 'package:rx/src/core/notifications.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

Operator<T, Notification<T>> materialize<T>() => _MaterializeOperator<T>();

class _MaterializeOperator<T> implements Operator<T, Notification<T>> {
  _MaterializeOperator();

  @override
  Subscription call(
          Observable<T> source, Observer<Notification<T>> destination) =>
      source.subscribe(_MaterializeSubscriber<T>(destination));
}

class _MaterializeSubscriber<T> extends Subscriber<T> {
  _MaterializeSubscriber(Observer<Notification<T>> destination)
      : super(destination);

  @override
  void onNext(T value) {
    destination.next(NextNotification<T>(value));
  }

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    destination.next(ErrorNotification<T>(error, stackTrace));
    destination.complete();
  }

  @override
  void onComplete() {
    destination.next(CompleteNotification<T>());
    destination.complete();
  }
}
