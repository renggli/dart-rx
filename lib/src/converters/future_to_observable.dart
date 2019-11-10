library rx.converters.future_to_observable;

import 'dart:async';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscription.dart';

extension FutureToObservable<T> on Future<T> {
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
