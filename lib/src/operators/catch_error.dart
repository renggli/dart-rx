library rx.operators.catch_error;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

typedef CatchErrorHandler<T> = Observable<T>
    Function(Observable<T> caught, Object error, [StackTrace stackTrace]);

/// Catches errors on the observable to be handled by returning a new
/// observable or throwing an error.
//Operator<T, T> catchError<T>(CatchErrorHandler<T> handler) =>
//    _CatchErrorOperator(handler);
//
//class _CatchErrorOperator<T> implements Operator<T, T> {
//  final CatchErrorHandler<T> handler;
//
//  _CatchErrorOperator(this.handler);
//
//  @override
//  Subscription call(Observable<T> source, Observer<T> destination) =>
//      source.subscribe(
//          _CatchErrorSubscriber(destination, handler, source.lift(this)));
//}
//
//class _CatchErrorSubscriber<T> extends OuterSubscriber<T, T> {
//  final CatchErrorHandler<T> handler;
//  final Observable<T> caught;
//
//  _CatchErrorSubscriber(Observer<T> destination, this.handler, this.caught)
//      : super(destination);
//
//  @override
//  void onError(Object error, [StackTrace stackTrace]) {
////    final observable = handler(caught, error, stackTrace);
////    for (final subscription in subscriptions) {
////      subscription.unsubscribe();
////    }
////    final innerSubscriber = InnerSubscriber(this, null, null);
////    add(innerSubscriber);
////    observable.subscribe(destination);
//  }
//}
