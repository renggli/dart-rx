library rx.operators.catch_error;

import '../constructors/from.dart';
import '../core/events.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';

typedef CatchHandler = Object Function(Object error, [StackTrace stackTrace]);

extension CatchErrorOperator<T> on Observable<T> {
  /// Catches errors on the observable to be handled by returning a new
  /// observable or throwing an error.
  Observable<T> catchError(CatchHandler handler) =>
      CatchErrorObservable<T>(this, handler);
}

class CatchErrorObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final CatchHandler handler;

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
  final CatchHandler handler;

  CatchErrorSubscriber(Observer<T> observer, this.handler) : super(observer);

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    final handlerEvent = Event.map2(handler, error, stackTrace);
    if (handlerEvent is ErrorEvent) {
      doError(handlerEvent.error, handlerEvent.stackTrace);
    } else {
      final observable = from<T>(handlerEvent.value);
      add(InnerObserver(observable, this));
    }
  }

  @override
  void notifyNext(Disposable subscription, void state, T value) =>
      doNext(value);

  @override
  void notifyError(Disposable subscription, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable subscription, void state) => doComplete();
}
