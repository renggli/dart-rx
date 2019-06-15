library rx.operators.catch_error;

import 'package:rx/src/constructors/from.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef CatchHandler<T> = Function(Object error, [StackTrace stackTrace]);

/// Catches errors on the observable to be handled by returning a new
/// observable or throwing an error.
Operator<T, T> catchError<T>(CatchHandler<T> handler) => (subscriber, source) =>
    source.subscribe(_CatchErrorSubscriber(subscriber, source, handler));

class _CatchErrorSubscriber<T> extends Subscriber<T> {
  final Observable<T> source;
  final CatchHandler<T> handler;

  _CatchErrorSubscriber(Observer<T> destination, this.source, this.handler)
      : super(destination);

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    final handlerEvent = Event.map2(handler, error, stackTrace);
    if (handlerEvent is ErrorEvent) {
      doError(handlerEvent.error, handlerEvent.stackTrace);
    } else {
      final observable = from<T>(handlerEvent.value);
      add(observable.subscribe(destination));
    }
  }
}
