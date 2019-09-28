library rx.operators.catch_error;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';

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
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(CatchErrorSubscriber<T>(observer, handler));
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
      final observable = Observable.from<T>(handlerEvent.value);
      add(InnerObserver(observable, this));
    }
  }

  @override
  void notifyNext(Subscription subscription, void state, T value) =>
      doNext(value);

  @override
  void notifyError(Subscription subscription, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Subscription subscription, void state) => doComplete();
}
