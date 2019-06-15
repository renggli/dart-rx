library rx.operators.dematerialize;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

Operator<Event<T>, T> dematerialize<T>() => (subscriber, source) =>
    source.subscribe(_DematerializeSubscriber<T>(subscriber));

class _DematerializeSubscriber<T> extends Subscriber<Event<T>> {
  _DematerializeSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(Event<T> value) {
    if (value is NextEvent<T>) {
      doNext(value.value);
    } else if (value is ErrorEvent<T>) {
      doError(value.error, value.stackTrace);
    } else if (value is CompleteEvent<T>) {
      doComplete();
    }
  }
}
