library rx.operators.distinct_until_changed;

import 'package:rx/src/core/notifications.dart';
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
        DistinctUntilChangedEqualsFunction<T, K> equals}) =>
    (subscriber, source) => source.subscribe(_DistinctUntilChangedSubscriber(
          subscriber,
          key ?? (value) => value as K,
          equals ?? (a, b) => a == b,
        ));

class _DistinctUntilChangedSubscriber<T, K> extends Subscriber<T> {
  final DistinctUntilChangedKeySelectorFunction<T, K> key;
  final DistinctUntilChangedEqualsFunction<T, K> equals;

  bool seenKey = false;
  K lastKey;

  _DistinctUntilChangedSubscriber(
      Observer<T> destination, this.key, this.equals)
      : super(destination);

  @override
  void onNext(T value) {
    final keyNotification = Notification.run(() => key(value));
    if (keyNotification is ErrorNotification) {
      doError(keyNotification.error, keyNotification.stackTrace);
      return;
    }
    if (seenKey) {
      final comparisonNotification =
          Notification.run(() => equals(lastKey, keyNotification.value));
      if (comparisonNotification is ErrorNotification) {
        doError(
            comparisonNotification.error, comparisonNotification.stackTrace);
        return;
      } else if (comparisonNotification.value) {
        return;
      } else {
        lastKey = keyNotification.value;
      }
    } else {
      lastKey = keyNotification.value;
      seenKey = true;
    }
    doNext(value);
  }
}
