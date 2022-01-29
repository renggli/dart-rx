import '../../core/observable.dart';
import '../../core/observer.dart';
import '../../disposables/disposable.dart';
import '../store.dart';

extension ObservableStoreExtension<S> on Store<S> {
  /// Adds an [observable] that asynchronously contributes to the state through
  /// [next], [error] and [complete] reducers. These functions receive the
  /// current state and the events of the [Observer] to produce a new state.
  Disposable addObservable<T>(
    Observable<T> observable, {
    S Function(S state, T value)? next,
    S Function(S state, Object error, StackTrace stackTrace)? error,
    S Function(S state)? complete,
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
}
