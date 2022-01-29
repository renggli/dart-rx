import '../../core.dart';
import 'stores/base.dart';
import 'stores/validating.dart';
import 'types.dart';

/// A redux like store that manages state.
///
/// Contrary to the original design the store doesn't use configured actions,
/// but instead can be updated synchronously with [update] or asynchronously
/// by passing an observable and a reducer function to [addReducer].
///
/// The current state can be accessed with the [state] accessor. The store
/// is an [Observable], changes can be transformed using rx operators and
/// listened to by subscribing.
///
/// The canonical example with the counter looks like this:
///
///    // Create a store with the initial value 0.
///    final store = Store<int>(0);
///
///    // Subscribe to state changes and print the new state to the console.
///    store.subscribe(Observer.next((state) => print(state)));
///
///    // Increment the value by one. In a more complicated example one
///    // could extract the function to be standalone, or generalize it to
///    // handle different actions.
///    store.update((state) => state + 1);
///
///    // Alternatively, one can subscribe to an observable and provide
///    // reducer functions for its events to update the state asynchronously.
///    // The following lines set the state to a random value every 10 seconds.
///    final randomValue = timer(period: Duration(seconds: 10))
///       .map((_) => Random().nextInt(100));
///    store.addReducer(randomValue, next: (state, value) => value);
///
abstract class Store<S> implements Observable<S> {
  /// Constructs a store from an initial value.
  factory Store(S initialValue) {
    Store<S> store = BaseStore<S>(initialValue);
    // If assertions are enabled, wrap it in a validating store.
    assert(() {
      store = ValidatingStore<S>(store);
      return true;
    }());
    return store;
  }

  /// Returns the current state.
  S get state;

  /// Updates the current state.
  S update(Updater<S> updater);
}
