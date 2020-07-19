library rx.operators.catch_error;

import '../constructors/empty.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';
import '../observers/inner.dart';

/// Handles errors, and returns a new [Observable] or `null`.
typedef ErrorHandler<T> = Observable<T> Function(Object error,
    [StackTrace stackTrace]);

extension CatchErrorOperator<T> on Observable<T> {
  /// Catches errors of this [Observable] and handles them by either returning
  /// a new [Observable] or throwing an error.
  Observable<T> catchError(ErrorHandler<T> handler) =>
      CatchErrorObservable<T>(this, handler);
}

class CatchErrorObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final ErrorHandler<T> handler;

  CatchErrorObservable(this.delegate, this.handler);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = CatchErrorSubscriber<T>(observer, handler);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class CatchErrorSubscriber<T> extends Subscriber<T>
    implements InnerEvents<T, void> {
  final ErrorHandler<T> handler;

  CatchErrorSubscriber(Observer<T> observer, this.handler) : super(observer);

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    final handlerEvent = Event.map2(handler, error, stackTrace);
    if (handlerEvent.isError) {
      doError(handlerEvent.error, handlerEvent.stackTrace);
    } else {
      add(InnerObserver(this, handlerEvent.value ?? empty<T>()));
    }
  }

  @override
  void notifyNext(Disposable disposable, void state, T value) => doNext(value);

  @override
  void notifyError(Disposable disposable, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) => doComplete();
}
