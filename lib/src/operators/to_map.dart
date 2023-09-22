import 'package:more/collection.dart' show ListMultimap, SetMultimap;
import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension ToMapOperator<T> on Observable<T> {
  /// Returns a [Map] from an observable sequence.
  Observable<Map<K, V>> toMap<K, V>(
          {Map0<Map<K, V>>? constructor,
          Map1<T, K>? keySelector,
          Map1<T, V>? valueSelector}) =>
      ToMapObservable<T, Map<K, V>, K, V>(
          this,
          constructor ?? () => <K, V>{},
          keySelector ?? (value) => value as K,
          valueSelector ?? (value) => value as V,
          (map, key, value) => map[key] = value);

  /// Returns a [ListMultimap] from an observable sequence.
  Observable<ListMultimap<K, V>> toListMultimap<K, V>(
          {Map0<ListMultimap<K, V>>? constructor,
          Map1<T, K>? keySelector,
          Map1<T, V>? valueSelector}) =>
      ToMapObservable<T, ListMultimap<K, V>, K, V>(
          this,
          constructor ?? ListMultimap<K, V>.new,
          keySelector ?? (value) => value as K,
          valueSelector ?? (value) => value as V,
          (map, key, value) => map.add(key, value));

  /// Returns a [SetMultimap] from an observable sequence.
  Observable<SetMultimap<K, V>> toSetMultimap<K, V>(
          {Map0<SetMultimap<K, V>>? constructor,
          Map1<T, K>? keySelector,
          Map1<T, V>? valueSelector}) =>
      ToMapObservable<T, SetMultimap<K, V>, K, V>(
          this,
          constructor ?? SetMultimap<K, V>.new,
          keySelector ?? (value) => value as K,
          valueSelector ?? (value) => value as V,
          (map, key, value) => map.add(key, value));
}

class ToMapObservable<T, M, K, V> implements Observable<M> {
  ToMapObservable(this.delegate, this.constructor, this.keySelector,
      this.valueSelector, this.addSelector);

  final Observable<T> delegate;
  final Map0<M> constructor;
  final Map1<T, K> keySelector;
  final Map1<T, V> valueSelector;
  final Callback3<M, K, V> addSelector;

  @override
  Disposable subscribe(Observer<M> observer) {
    final subscriber = ToMapSubscriber<T, M, K, V>(
        observer, constructor(), keySelector, valueSelector, addSelector);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ToMapSubscriber<T, M, K, V> extends Subscriber<T> {
  ToMapSubscriber(Observer<M> super.observer, this.map, this.keySelector,
      this.valueSelector, this.addSelector);

  final M map;
  final Map1<T, K> keySelector;
  final Map1<T, V> valueSelector;
  final Callback3<M, K, V> addSelector;

  @override
  void onNext(T value) {
    try {
      addSelector(map, keySelector(value), valueSelector(value));
    } catch (error, stackTrace) {
      doError(error, stackTrace);
    }
  }

  @override
  void onComplete() {
    doNext(map);
    doComplete();
  }
}
