import '../constructors/empty.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';
import '../observers/inner.dart';

/// Handles errors of type [E], and returns a new [Observable] of type [T],
/// or `null` if the [Observable] should be completed.
typedef ErrorHandler<T, E> = Observable<T>? Function(
    E error, StackTrace stackTrace);

extension CatchErrorOperator<T> on Observable<T> {
  /// Catches errors of type [E] thrown by this [Observable] and handles them
  /// by either returning a new [Observable] of type [T], throwing the same or
  /// a different error, or returning `null` to complete the [Observable].
  Observable<T> catchError<E>(ErrorHandler<T, E> handler) =>
      CatchErrorObservable<T, E>(this, handler);
}

class CatchErrorObservable<T, E> implements Observable<T> {
  CatchErrorObservable(this.delegate, this.handler);

  final Observable<T> delegate;
  final ErrorHandler<T, E> handler;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = CatchErrorSubscriber<T, E>(observer, handler);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class CatchErrorSubscriber<T, E> extends Subscriber<T>
    implements InnerEvents<T, void> {
  CatchErrorSubscriber(Observer<T> super.observer, this.handler);

  final ErrorHandler<T, E> handler;

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (error is E) {
      final handlerEvent = Event.map2(handler, error as E, stackTrace);
      if (handlerEvent.isError) {
        doError(handlerEvent.error, handlerEvent.stackTrace);
      } else {
        add(InnerObserver(this, handlerEvent.value ?? empty(), null));
      }
    } else {
      doError(error, stackTrace);
    }
  }

  @override
  void notifyNext(Disposable disposable, void state, T value) => doNext(value);

  @override
  void notifyError(Disposable disposable, void state, Object error,
          StackTrace stackTrace) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) => doComplete();
}
