library rx.operators.to_map;

import 'package:more/collection.dart' show ListMultimap, SetMultimap;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

extension ToMapOperator<T> on Observable<T> {
  /// Returns a [Map] from an observable sequence.
  Observable<Map<K, V>> toMap<K, V>(
          {Map0<Map<K, V>> mapConstructor,
          Map1<T, K> keySelector,
          Map1<T, V> valueSelector}) =>
      ToMapObservable<T, Map<K, V>, K, V>(
          this,
          mapConstructor ?? () => <K, V>{},
          keySelector ?? (value) => value as K,
          valueSelector ?? (value) => value as V,
          (map, key, value) => map[key] = value);

  /// Returns a [ListMultimap] from an observable sequence.
  Observable<ListMultimap<K, V>> toListMultimap<K, V>(
          {Map0<ListMultimap<K, V>> multimapConstructor,
          Map1<T, K> keySelector,
          Map1<T, V> valueSelector}) =>
      ToMapObservable<T, ListMultimap<K, V>, K, V>(
          this,
          multimapConstructor ?? () => ListMultimap<K, V>(),
          keySelector ?? (value) => value as K,
          valueSelector ?? (value) => value as V,
          (map, key, value) => map.add(key, value));

  /// Returns a [SetMultimap] from an observable sequence.
  Observable<SetMultimap<K, V>> toSetMultimap<K, V>(
          {Map0<SetMultimap<K, V>> multimapConstructor,
          Map1<T, K> keySelector,
          Map1<T, V> valueSelector}) =>
      ToMapObservable<T, SetMultimap<K, V>, K, V>(
          this,
          multimapConstructor ?? () => SetMultimap<K, V>(),
          keySelector ?? (value) => value as K,
          valueSelector ?? (value) => value as V,
          (map, key, value) => map.add(key, value));
}

class ToMapObservable<T, M, K, V> extends Observable<M> {
  final Observable<T> delegate;
  final Map0<M> mapConstructor;
  final Map1<T, K> keySelector;
  final Map1<T, V> valueSelector;
  final Callback3<M, K, V> addSelector;

  ToMapObservable(this.delegate, this.mapConstructor, this.keySelector,
      this.valueSelector, this.addSelector);

  @override
  Disposable subscribe(Observer<M> observer) {
    final subscriber = ToMapSubscriber<T, M, K, V>(
        observer, mapConstructor(), keySelector, valueSelector, addSelector);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ToMapSubscriber<T, M, K, V> extends Subscriber<T> {
  final M map;
  final Map1<T, K> keySelector;
  final Map1<T, V> valueSelector;
  final Callback3<M, K, V> addSelector;

  ToMapSubscriber(Observer<M> observer, this.map, this.keySelector,
      this.valueSelector, this.addSelector)
      : super(observer);

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
