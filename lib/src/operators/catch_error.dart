library rx.operators.catch_error;

import 'package:rx/src/constructors/from.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';

typedef CatchHandler<T> = Function(Object error, [StackTrace stackTrace]);

/// Catches errors on the observable to be handled by returning a new
/// observable or throwing an error.
OperatorFunction<T, T> catchError<T>(CatchHandler<T> handler) =>
    (source) => source.lift((source, subscriber) => source
        .subscribe(_CatchErrorSubscriber<T>(source, subscriber, handler)));

class _CatchErrorSubscriber<T> extends Subscriber<T>
    implements InnerEvents<T, void> {
  final Observable<T> source;
  final CatchHandler<T> handler;

  _CatchErrorSubscriber(this.source, Observer<T> destination, this.handler)
      : super(destination);

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
  void notifyNext(Subscription subscription, void state, T value) =>
      doNext(value);

  @override
  void notifyError(Subscription subscription, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Subscription subscription, void state) => doComplete();
}
