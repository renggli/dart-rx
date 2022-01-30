import '../../core/observer.dart';
import '../../disposables/disposable.dart';
import '../store.dart';
import '../types.dart';

/// A delegating store that validates state access and updates.
class ValidatingStore<S> implements Store<S> {
  /// Constructs a validating store.
  ValidatingStore(this.delegate);

  /// The store to delegate operations to.
  final Store<S> delegate;

  /// Flag indicating whether the store is currently being updated.
  bool isUpdating = false;

  @override
  S get state {
    if (isUpdating) {
      throw StateError(
          'You may not call `Store.state` while updating. The update function '
          'has already received the state as an argument. Pass it down the '
          'call chain instead of reading a possibly outdated version from the '
          'store.');
    }
    return delegate.state;
  }

  @override
  S update(Updater<S> updater) {
    if (isUpdating) {
      throw StateError(
          'You may not call `Store.update` while updating. The update function '
          'has already received the state as an argument. Pass it down the '
          'call chain to manipulate it.');
    }
    isUpdating = true;
    try {
      return delegate.update(updater);
    } finally {
      isUpdating = false;
    }
  }

  @override
  Disposable subscribe(Observer<S> observer) => delegate.subscribe(observer);
}
