import '../store.dart';

extension FutureStoreExtension<S> on Store<S> {
  /// Adds an [future] that asynchronously contributes to the state through
  /// [onValue] and [onError] reducers. These functions receive the current
  /// state and resolution of the [Future] to produce a new state.
  Future<S> addFuture<T>(
    Future<T> future, {
    S Function(S state, T value)? onValue,
    S Function(S state, Object error, StackTrace stackTrace)? onError,
  }) =>
      future.then(
        (value) =>
            onValue == null ? state : update((state) => onValue(state, value)),
        onError: onError == null
            ? null
            : (Object exception, StackTrace stackTrace) =>
                update((state) => onError(state, exception, stackTrace)),
      );
}
