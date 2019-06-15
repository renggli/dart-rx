library rx.operators.filter;

import 'package:rx/core.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef FilterPredicate<T> = bool Function(T value);

/// Filter items emitted by the source Observable by only emitting those that
/// satisfy a specified predicate.
Operator<T, T> filter<T>(FilterPredicate predicate) => (subscriber, source) =>
    source.subscribe(_FilterSubscriber(subscriber, predicate));

class _FilterSubscriber<T> extends Subscriber<T> {
  final FilterPredicate<T> predicate;

  _FilterSubscriber(Observer<T> destination, this.predicate)
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
