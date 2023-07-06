import 'dart:async';

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../disposables/stateful.dart';

extension FutureToObservable<T> on Future<T> {
  /// Returns an [Observable] that listens to the completion of this [Future].
  Observable<T> toObservable() => FutureObservable<T>(this);
}

class FutureObservable<T> implements Observable<T> {
  const FutureObservable(this.future);

  final Future<T> future;

  @override
  Disposable subscribe(Observer<T> observer) =>
      FutureDisposable(future, observer);
}

class FutureDisposable<T> extends StatefulDisposable {
  FutureDisposable(this.future, this.observer) {
    future.then(onValue, onError: onError);
  }

  final Future<T> future;
  final Observer<T> observer;

  void onValue(T value) {
    if (isDisposed) return;
    observer.next(value);
    observer.complete();
  }

  void onError(Object error, StackTrace stackTrace) {
    if (isDisposed) return;
    observer.error(error, stackTrace);
  }
}
