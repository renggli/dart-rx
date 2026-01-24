import 'disposable.dart';

/// A [Disposable] that adds an
abstract class CollectionDisposable<T> implements Disposable {
  /// Adds [value] to [list] and returns a [Disposable] that removes the value
  /// again on disposal.
  ///
  /// For example:
  ///
  /// ```dart
  /// final list = <int>[];
  /// final disposable = CollectionDisposable.forList(list, 1);
  /// print(list); // [1]
  /// disposable.dispose();
  /// print(list); // []
  /// ```
  factory CollectionDisposable.forList(List<T> list, T value) = _ListDisposable;

  /// Adds [value] to [set] and returns a [Disposable] that removes the value
  /// again on disposal.
  ///
  /// For example:
  ///
  /// ```dart
  /// final set = <int>{};
  /// final disposable = CollectionDisposable.forSet(set, 1);
  /// print(set); // {1}
  /// disposable.dispose();
  /// print(set); // {}
  /// ```
  factory CollectionDisposable.forSet(Set<T> set, T value) = _SetDisposable;

  CollectionDisposable(this._value);

  Iterable<T> get _collection;

  final T _value;

  @override
  bool get isDisposed => !_collection.contains(_value);
}

class _ListDisposable<T> extends CollectionDisposable<T> {
  _ListDisposable(this._collection, super._value) {
    _collection.add(_value);
  }

  @override
  final List<T> _collection;

  @override
  void dispose() => _collection.remove(_value);
}

class _SetDisposable<T> extends CollectionDisposable<T> {
  _SetDisposable(this._collection, super._value) {
    _collection.add(_value);
  }

  @override
  final Set<T> _collection;

  @override
  void dispose() => _collection.remove(_value);
}
