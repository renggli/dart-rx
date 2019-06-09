library rx.operators.finalize;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/subscriptions/anonymous.dart';

typedef FinalizeFunction = void Function();

/// Returns an Observable that mirrors the source Observable, but will call a
/// specified function when the source terminates on complete or error.
Operator<T, T> finalize<T>(FinalizeFunction finalizeFunction) =>
    _FinalizeOperator(finalizeFunction);

class _FinalizeOperator<T> implements Operator<T, T> {
  final FinalizeFunction finalize;

  _FinalizeOperator(this.finalize);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) {
    final subscriber = Subscriber<T>(destination);
    subscriber.add(AnonymousSubscription(finalize));
    return source.subscribe(subscriber);
  }
}
