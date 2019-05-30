library rx.operators.dematerialize;

import 'package:rx/src/core/notifications.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

Operator<Notification<T>, T> dematerialize<T>() =>
    _DematerializeOperator<T>();

class _DematerializeOperator<T> implements Operator<Notification<T>, T> {
  _DematerializeOperator();

  @override
  Subscription call(
          Observable<Notification<T>> source, Observer<T> destination) =>
      source.subscribe(_DematerializeSubscriber<T>(destination));
}

class _DematerializeSubscriber<T> extends Subscriber<Notification<T>> {
  _DematerializeSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(Notification<T> value) => value.observe(destination);
}
