library rx.core.functions;

/// Function type used to pass a value.
typedef NextCallback<T> = void Function(T value);

/// Function type used to complete a sequence of values with a failure.
typedef ErrorCallback = void Function(Object error, [StackTrace stackTrace]);

/// Function type used to complete a sequence of values with a success.
typedef CompleteCallback = void Function();

/// Function type to map from a value of type `T` to a value of type `R`.
typedef MapFunction<T, R> = R Function(T value);

/// The null function.
void nullFunction() {}

/// The identity function.
T identityFunction<T>(T argument) => argument;

/// The constant functions.
T Function() constantFunction0<T>(T value) => () => value;
T Function(T1) constantFunction1<T, T1>(T value) => (T1 t1) => value;
