library rx.operators.catch_error;

import 'package:rx/core.dart';
import 'package:rx/src/constructors/from.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef CatchErrorHandler<T> = Function(Object error, [StackTrace stackTrace]);

/// Catches errors on the observable to be handled by returning a new
/// observable or throwing an error.
Operator<T, T> catchError<T>(CatchErrorHandler<T> handler) =>
    (subscriber, source) =>
        source.subscribe(_CatchErrorSubscriber(subscriber, source, handler));

class _CatchErrorSubscriber<T> extends Subscriber<T> {
  final Observable<T> source;
  final CatchErrorHandler<T> handler;

  _CatchErrorSubscriber(Observer<T> destination, this.source, this.handler)
      : super(destination);

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    Observable<T> observable;
    try {
      observable = from<T>(handler(error, stackTrace));
    } catch (error, stackTrace) {
      doError(error, stackTrace);
      return;
    }
    add(observable.subscribe(destination));
  }
}
