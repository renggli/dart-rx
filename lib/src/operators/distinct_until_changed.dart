library rx.operators.distinct_until_changed;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef DistinctUntilChangedKeySelectorFunction<T, K> = K Function(T value);
typedef DistinctUntilChangedEqualsFunction<T, K> = bool Function(
    K value1, K value2);

/// Emits all items emitted by the source Observable that are distinct
/// from the previous item.
Operator<T, T> distinctUntilChanged<T, K>(
        {DistinctUntilChangedKeySelectorFunction<T, K> key,
        DistinctUntilChangedEqualsFunction<T, K> compare}) =>
    (subscriber, source) => source.subscribe(_DistinctUntilChangedSubscriber(
          subscriber,
          key ?? (value) => value as K,
          compare ?? (a, b) => a == b,
        ));

class _DistinctUntilChangedSubscriber<T, K> extends Subscriber<T> {
  final DistinctUntilChangedKeySelectorFunction<T, K> key;
  final DistinctUntilChangedEqualsFunction<T, K> compare;

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
