/// Callback type used to pass a value.
typedef NextCallback<T> = void Function(T value);

/// Callback type used to complete a sequence of values with a failure.
typedef ErrorCallback = void Function(Object error, StackTrace stackTrace);

/// Callback type used to complete a sequence of values with a success.
typedef CompleteCallback = void Function();
