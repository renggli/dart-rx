library rx.operators.take_while;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Emits values while the [predicate] returns `true`.
Map1<Observable<T>, Observable<T>> takeWhile<T>(Predicate1<T> predicate) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_TakeWhileSubscriber<T>(subscriber, predicate)));

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
