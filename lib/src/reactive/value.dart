import 'package:meta/meta.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/collection.dart';
import '../disposables/disposable.dart';

/// Abstract reactive value
abstract class Value<T> implements Observable<T> {
  /// The currently held value.
  T get value;

  /// The observers monitoring changes of this value.
  final Set<Observer<T>> _observers = {};

  /// Subscribes to changes of this value.
  @override
  Disposable subscribe(Observer<T> observer) =>
      CollectionDisposable<Observer<T>>.forSet(_observers, observer);

  /// Update all registered observers of this value.
  @protected
  void update(T value) {
    for (final observer in _observers) {
      observer.next(value);
    }
  }
}

Observer<Never>? active;
