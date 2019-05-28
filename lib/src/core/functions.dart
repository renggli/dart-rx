library rx.core.functions;

typedef NextFunction<T> = void Function(T value);

typedef ErrorFunction = void Function(Object error, [StackTrace stackTrace]);

typedef CompleteFunction = void Function();
