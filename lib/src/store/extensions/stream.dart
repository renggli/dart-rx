import 'dart:async';

import '../store.dart';

extension StreamStoreExtension<S> on Store<S> {
  /// Adds a [stream] that asynchronously contributes to the state through
  /// [onData], [onError] and [onDone] reducers. These functions receive the
  /// current state and the events of the [Stream] to produce a new state.
  StreamSubscription<T> addStream<T>(
    Stream<T> stream, {
    S Function(S state, T event)? onData,
    S Function(S state, Object error, StackTrace stackTrace)? onError,
    S Function(S state)? onDone,
    bool? cancelOnError,
  }) =>
      stream.listen(
          onData == null
              ? null
              : (event) => update((state) => onData(state, event)),
          onError: onError == null
              ? null
              : (Object error, StackTrace stackTrace) =>
                  update((state) => onError(state, error, stackTrace)),
          onDone: onDone == null ? null : () => update(onDone),
          cancelOnError: cancelOnError);
}
