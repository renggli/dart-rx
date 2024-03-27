import 'disposable.dart';

/// A [Disposable] that adds an
abstract class CollectionDisposable<T> implements Disposable {
  /// Adds [value] to [list] and returns a [Disposable] that removes the value
  /// again on disposal.
  factory CollectionDisposable.forList(List<T> list, T value) = _ListDisposable;

  /// Adds [value] to [set] and returns a [Disposable] that removes the value
  /// again on disposal.
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
