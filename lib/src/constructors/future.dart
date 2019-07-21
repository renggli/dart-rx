library rx.constructors.future;

import 'dart:async';

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/base.dart';
import 'package:rx/src/subscriptions/composite.dart';
import 'package:rx/src/subscriptions/stateful.dart';

/// An [Observable] that listens to the completion of a [Future].
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

/// A [Future] that completes with the first value of an [Observable].
Future<T> toFuture<T>(Observable<T> observable) {
  final subscriptions = CompositeSubscription();
  final completer = Completer<T>();
  final observer = BaseObserver<T>(
    (value) {
      completer.complete(value);
      subscriptions.unsubscribe();
    },
    (error, [stackTrace]) {
      completer.completeError(error, stackTrace);
      subscriptions.unsubscribe();
    },
    () {
      completer.completeError(TooFewError());
      subscriptions.unsubscribe();
    },
  );
  subscriptions.add(observer);
  subscriptions.add(observable.subscribe(observer));
  return completer.future;
}
