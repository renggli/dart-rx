library rx.constructors.future;

import 'dart:async';

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

extension FromFutureConstructor<T> on Future<T> {
  /// An [Observable] that listens to the completion of a [Future].
  Observable<T> toObservable() => FutureObservable<T>(this);
}

class FutureObservable<T> with Observable<T> {
  final Future<T> future;

  const FutureObservable(this.future);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscription = Subscription.stateful();
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

extension ToFutureConstructor<T> on Observable<T> {
  /// A [Future] that completes with the first value of an [Observable].
  Future<T> toFuture() {
    final subscriptions = Subscription.composite();
    final completer = Completer<T>();
    final observer = Observer(
      next: (value) {
        completer.complete(value);
        subscriptions.unsubscribe();
      },
      error: (error, [stackTrace]) {
        completer.completeError(error, stackTrace);
        subscriptions.unsubscribe();
      },
      complete: () {
        completer.completeError(TooFewError());
        subscriptions.unsubscribe();
      },
    );
    subscriptions.add(observer);
    subscriptions.add(subscribe(observer));
    return completer.future;
  }
}
