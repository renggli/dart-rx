/// Callback type used to pass a value.
typedef NextCallback<T> = void Function(T value);

/// Callback type used to complete a sequence of values with a failure.
typedef ErrorCallback = void Function(Object error, StackTrace stackTrace);

/// Callback type used to complete a sequence of values with a success.
typedef CompleteCallback = void Function();

/// Function type for generic callbacks.
typedef Callback0 = void Function();
typedef Callback1<T1> = void Function(T1 arg1);
typedef Callback2<T1, T2> = void Function(T1 arg1, T2 arg2);
typedef Callback3<T1, T2, T3> = void Function(T1 arg1, T2 arg2, T3 arg3);

/// Function type for generic mapping functions.
typedef Map0<R> = R Function();
typedef Map1<T1, R> = R Function(T1 arg1);
typedef Map2<T1, T2, R> = R Function(T1 arg1, T2 arg2);
typedef Map3<T1, T2, T3, R> = R Function(T1 arg1, T2 arg2, T3 arg3);

/// Function type for a predicate from a value of type `T`.
typedef Predicate0 = bool Function();
typedef Predicate1<T1> = bool Function(T1 arg1);
typedef Predicate2<T1, T2> = bool Function(T1 arg1, T2 arg2);
typedef Predicate3<T1, T2, T3> = bool Function(T1 arg1, T2 arg2, T3 arg3);

/// The null functions.
void nullFunction0() {}

void nullFunction1<T1>(T1 arg1) {}

void nullFunction2<T1, T2>(T1 arg1, T2 arg2) {}

void nullFunction3<T1, T2, T3>(T1 arg1, T2 arg2, T3 arg3) {}

/// The identity function.
T identityFunction<T>(T argument) => argument;

/// The constant functions.
Map0<R> constantFunction0<R>(R value) => () => value;

Map1<T1, R> constantFunction1<T1, R>(R value) => (arg1) => value;

Map2<T1, T2, R> constantFunction2<T1, T2, R>(R value) => (arg1, arg2) => value;

Map3<T1, T2, T3, R> constantFunction3<T1, T2, T3, R>(R value) =>
    (arg1, arg2, arg3) => value;

/// The throwing functions.
Map0<R> throwFunction0<R>(Object throwable) => () => throw throwable;

Map1<T1, R> throwFunction1<T1, R>(Object throwable) =>
    (arg1) => throw throwable;

Map2<T1, T2, R> throwFunction2<T1, T2, R>(Object throwable) =>
    (arg1, arg2) => throw throwable;

Map3<T1, T2, T3, R> throwFunction3<T1, T2, T3, R>(Object throwable) =>
    (arg1, arg2, arg3) => throw throwable;
