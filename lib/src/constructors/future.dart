library rx.constructors.future;

import 'dart:async';

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/subscriptions/stateful.dart';

/// An [Observable] that emits on completion of a [Future].
Observable<T> fromFuture<T>(Future<T> future) => _FutureObservable<T>(future);

class _FutureObservable<T> with Observable<T> {
  final Future<T> future;

  const _FutureObservable(this.future);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscription = StatefulSubscription();
    future.then(
      (value) => _onValue(subscription, observer, value),
      onError: (error, stackTrace) =>
          _onError(subscription, observer, error, stackTrace),
    );
    return subscription;
  }

  void _onValue(Subscription subscription, Observer<T> observer, T value) {
    if (subscription.isClosed) {
      return;
    }
    observer.next(value);
    observer.complete();
  }

  void _onError(Subscription subscription, Observer<T> observer, Object error,
      StackTrace stackTrace) {
    if (subscription.isClosed) {
      return;
    }
    observer.error(error, stackTrace);
  }
}
