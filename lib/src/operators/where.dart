library rx.operators.where;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Filter items emitted by the source Observable by only emitting those that
/// satisfy a specified predicate.
OperatorFunction<T, T> where<T>(Predicate1<T> predicate) =>
    (source) => source.lift<T>((source, subscriber) =>
        source.subscribe(_WhereSubscriber<T>(subscriber, predicate)));

class _WhereSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;

  _WhereSubscriber(Observer<T> destination, this.predicate)
      : super(destination);

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent is ErrorEvent) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      doNext(value);
    }
  }
}
