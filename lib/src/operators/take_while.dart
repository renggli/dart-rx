library rx.operators.take_while;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Emits values while the [predicate] returns `true`.
Operator<T, T> takeWhile<T>(Predicate1<T> predicate) => (subscriber, source) =>
    source.subscribe(_TakeWhileSubscriber(subscriber, predicate));

class _TakeWhileSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;

  _TakeWhileSubscriber(Observer<T> destination, this.predicate)
      : super(destination);

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent is ErrorEvent) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      doNext(value);
    } else {
      doComplete();
    }
  }
}
