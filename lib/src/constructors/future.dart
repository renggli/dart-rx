library rx.constructors.future;

import 'dart:async';

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

/// An [Observable] that emits on completion of a [Future].
Observable<T> fromFuture<T>(Future<T> future) => _FutureObservable<T>(future);

class _FutureObservable<T> with Observable<T> {
  final Future<T> future;

  _FutureObservable(this.future);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscription = ActiveSubscription();
    future.then((value) {
      if (subscription.isSubscribed) {
        observer.next(value);
        observer.complete();
      }
    }, onError: (error, stackTrace) {
      if (subscription.isSubscribed) {
        observer.error(error, stackTrace);
      }
    });
    return subscription;
  }
}
