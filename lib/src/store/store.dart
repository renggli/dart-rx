import 'package:rx/core.dart';
import 'package:rx/disposables.dart';

import 'types.dart';

/// A redux like store that manages state.
///
/// Contrary to the original design the store doesn't use configured actions,
/// but instead can be updated synchronously with [update] or asynchronously
/// by passing an observable and a reducer function to [addReducer].
///
/// The current state can be accessed with the [state] accessor. Listeners to
/// state changes are added by calling [addListener].
///
/// The canonical example with the counter looks like this:
///
///    // Create a store with the initial value 0.
///    final store = Store<int>(0);
///
///    // Add a listener that prints the state whenever updated to console.
///    store.addListener((state) => print(state));
///
///    // Increment the value by one. In a more complicated example one
///    // could extract the function to be standalone, or generalize it to
///    // handle different actions.
///    store.update((state) => state + 1);
///
///    // Alternatively, one can subscribe to an observable and provide
///    // reducer functions for its events to update the state asynchronously.
///    // The following line sets the state to a random value every 10 seconds.
///    const randomValueEvery10sec = timer(period: Duration(seconds: 10))
///       .map((_) => Random().nextInt(100));
///    store.addReducer(randomValueEvery10sec, next: (state, value) => value);
///
class Store<S> {
  /// Constructs the store with the given initial state.
  Store(this._state);

  /// Internal: reference to the current state.
  S _state;

  /// Internal: flag indicating whether an update is happening right now.
  bool _isUpdating = false;

  /// Internal: list of listeners to be called with state changes.
  final List<Listener<S>> _listeners = [];

  /// Returns the current state.
  S get state {
    if (_isUpdating) {
      throw StateError('You may not call Store.state while updating. '
          'The update function has already received the state as an argument. '
          'Pass it down the call chain instead of reading a possibly outdated '
          'version from the store.');
    }
    return _state;
  }

  /// Updates the state asynchronously with an [updater] function.
  S update(Updater<S> updater) {
    if (_isUpdating) {
      throw StateError('You may not call Store.update while updating. '
          'The update function has already received the state as an argument. '
          'Pass it down the call chain to manipulate it.');
    }
    _isUpdating = true;
    try {
      _state = updater(_state);
    } finally {
      _isUpdating = false;
    }
    for (var listener in [..._listeners]) {
      listener(_state);
    }
    return _state;
  }

  /// Adds an [observable] that contributes to the state through a set of
  /// reducer functions: [next], [error] and [complete]. These functions receive
  /// the current state and the events of the observer to produce a new state.
  Disposable addReducer<T>(
    Observable<T> observable, {
    NextReducer<S, T>? next,
    ErrorReducer<S>? error,
    CompleteReducer<S>? complete,
    bool ignoreErrors = false,
  }) =>
      observable.subscribe(Observer(
        next: next == null
            ? null
            : (value) => update((state) => next(state, value)),
        error: error == null
            ? null
            : (exception, stackTrace) =>
                update((state) => error(state, exception, stackTrace)),
        complete: complete == null ? null : () => update(complete),
        ignoreErrors: ignoreErrors,
      ));

  /// Adds a listener that gets called whenever the state changes.
  Disposable addListener(Listener<S> listener) {
    _listeners.add(listener);
    return ActionDisposable(() => _listeners.remove(listener));
  }
}
