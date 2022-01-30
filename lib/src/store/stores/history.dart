import 'dart:collection';

import 'package:more/functional.dart';

import '../../core/observer.dart';
import '../../disposables/disposable.dart';
import '../store.dart';
import '../types.dart';

/// A store that captures the history and enables undo and redo operations.
class HistoryStore<S> implements Store<S> {
  /// Constructs a history store.
  HistoryStore(this.delegate, {this.filter, this.limit});

  /// The store that manages the current state.
  final Store<S> delegate;

  /// An (optional) filter predicate to exclude certain states from the history.
  final Predicate1<S>? filter;

  /// An (optional) limit of history states to remember.
  final int? limit;

  /// Internal queue of the past history states.
  final _past = Queue<S>();

  /// Read-only accessor to the past history states.
  List<S> get past => [..._past];

  /// Internal queue of the future history states.
  final _future = Queue<S>();

  /// Read-only accessor to the future history states.
  List<S> get future => [..._future];

  /// Tests if the last change to the store can be undone.
  bool get canUndo => _past.isNotEmpty;

  /// Undoes the last change to the store.
  S undo() {
    final target = _past.removeLast();
    return delegate.update((state) {
      _future.addFirst(state);
      return target;
    });
  }

  /// Tests if the last action can be redone.
  bool get canRedo => _future.isNotEmpty;

  /// Redoes the last change to the store.
  S redo() {
    final target = _future.removeFirst();
    return delegate.update((state) {
      _past.addLast(state);
      return target;
    });
  }

  /// Clears the undo/redo history.
  void clear() {
    _past.clear();
    _future.clear();
  }

  @override
  S get state => delegate.state;

  @override
  S update(Updater<S> updater) => delegate.update((state) {
        // Only remember the current state if it is not filtered.
        if (filter == null || !filter!(state)) {
          _past.addLast(state);
          // Limit the number of history items to remember.
          if (limit != null) {
            while (limit! < _past.length) {
              _past.removeFirst();
            }
          }
        }
        // Erase all future states.
        _future.clear();
        return updater(state);
      });

  @override
  Disposable subscribe(Observer<S> observer) => delegate.subscribe(observer);
}
