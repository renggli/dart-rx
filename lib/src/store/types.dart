typedef Listener<S> = void Function(S state);

typedef Updater<S> = S Function(S state);

typedef NextReducer<S, T> = S Function(S state, T value);

typedef ErrorReducer<S> = S Function(
    S state, Object error, StackTrace stackTrace);

typedef CompleteReducer<S> = S Function(S state);
