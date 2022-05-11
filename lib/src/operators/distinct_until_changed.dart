import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension DistinctUntilChangedOperator<T> on Observable<T> {
  /// Emits all items emitted by this [Observable] that are different from the
  /// previous one.
  Observable<T> distinctUntilChanged<K>(
          {Map1<T, K>? key, Predicate2<K, K>? compare}) =>
      DistinctUntilChangedObservable<T, K>(
        this,
        key ?? (value) => value as K,
        compare ?? (a, b) => a == b,
      );
}

class DistinctUntilChangedObservable<T, K> implements Observable<T> {
  DistinctUntilChangedObservable(this.delegate, this.key, this.compare);

  final Observable<T> delegate;
  final Map1<T, K> key;
  final Predicate2<K, K> compare;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber =
        DistinctUntilChangedSubscriber<T, K>(observer, key, compare);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class DistinctUntilChangedSubscriber<T, K> extends Subscriber<T> {
  DistinctUntilChangedSubscriber(
      Observer<T> super.observer, this.key, this.compare);

  final Map1<T, K> key;
  final Predicate2<K, K> compare;

  late K lastKey;
  bool seenKey = false;

  @override
  void onNext(T value) {
    final keyEvent = Event.map1(key, value);
    if (keyEvent.isError) {
      doError(keyEvent.error, keyEvent.stackTrace);
      return;
    }
    if (seenKey) {
      final compareEvent = Event.map2(compare, lastKey, keyEvent.value);
      if (compareEvent.isError) {
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
