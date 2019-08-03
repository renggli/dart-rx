library rx.operators.distinct_until_changed;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Emits all items emitted by the source Observable that are distinct
/// from the previous item.
OperatorFunction<T, T> distinctUntilChanged<T, K>(
        {Map1<T, K> key, Predicate2<K, K> compare}) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_DistinctUntilChangedSubscriber<T, K>(
          subscriber,
          key ?? (value) => value as K,
          compare ?? (a, b) => a == b,
        )));

class _DistinctUntilChangedSubscriber<T, K> extends Subscriber<T> {
  final Map1<T, K> key;
  final Predicate2<K, K> compare;

  bool seenKey = false;
  K lastKey;

  _DistinctUntilChangedSubscriber(
      Observer<T> destination, this.key, this.compare)
      : super(destination);

  @override
  void onNext(T value) {
    final keyEvent = Event.map1(key, value);
    if (keyEvent is ErrorEvent) {
      doError(keyEvent.error, keyEvent.stackTrace);
      return;
    }
    if (seenKey) {
      final compareEvent = Event.map2(compare, lastKey, keyEvent.value);
      if (compareEvent is ErrorEvent) {
        doError(compareEvent.error, compareEvent.stackTrace);
        return;
      } else if (compareEvent.value) {
        return;
      } else {
        lastKey = keyEvent.value;
      }
    } else {
      lastKey = keyEvent.value;
      seenKey = true;
    }
    doNext(value);
  }
}
