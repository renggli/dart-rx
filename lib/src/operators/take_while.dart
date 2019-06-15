library rx.operators.take_while;

import 'package:rx/core.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';

typedef TakeWhilePredicate<T> = bool Function(T value);

/// Emits values while the [predicate] returns `true`.
Operator<T, T> takeWhile<T>(TakeWhilePredicate predicate) =>
    (subscriber, source) =>
        source.subscribe(_TakeWhileSubscriber(subscriber, predicate));

class _TakeWhileSubscriber<T> extends Subscriber<T> {
  final TakeWhilePredicate predicate;

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
