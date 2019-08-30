library rx.operators.distinct_until_changed;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension DistinctUntilChangedOperator<T> on Observable<T> {
  /// Emits all items emitted by the source Observable that are distinct
  /// from the previous item.
  Observable<T> distinctUntilChanged<K>({Map1<T, K> key,
      Predicate2<K, K> compare})
    => DistinctUntilChangedObservable<T, K>(this, key, compare);
}

class DistinctUntilChangedObservable<T, K> extends Observable<T> {
  final Observable<T> delegate;
  final Map1<T, K> key;
  final Predicate2<K, K> compare;

  DistinctUntilChangedObservable(this.delegate, this.key, this.compare);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(
          DistinctUntilChangedSubscriber<T, K>(observer, key, compare));
}

class DistinctUntilChangedSubscriber<T, K> extends Subscriber<T> {
  final Map1<T, K> key;
  final Predicate2<K, K> compare;

  bool seenKey = false;
  K lastKey;

  DistinctUntilChangedSubscriber(
      Observer<T> observer, this.key, this.compare)
      : super(observer);

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
