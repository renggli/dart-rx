library rx.operators.skip_while;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Skips over the values while the [predicate] is `true`.
Map1<Observable<T>, Observable<T>> skipWhile<T>(Predicate1<T> predicate) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_SkipWhileSubscriber<T>(subscriber, predicate)));

class _SkipWhileSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;
  bool skipping = true;

  _SkipWhileSubscriber(Observer<T> destination, this.predicate)
      : super(destination);

  @override
  void onNext(T value) {
    if (skipping) {
      final predicateEvent = Event.map1(predicate, value);
      if (predicateEvent is ErrorEvent) {
        doError(predicateEvent.error, predicateEvent.stackTrace);
      } else if (!predicateEvent.value) {
        skipping = false;
        doNext(value);
      }
    } else {
      doNext(value);
    }
  }
}
