import 'dart:async';

import '../core/errors.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/composite.dart';

extension ObservableToFuture<T> on Observable<T> {
  /// Returns a [Future] that completes with the first value of this
  /// [Observable].
  Future<T> toFuture() {
    final disposable = CompositeDisposable();
    final completer = Completer<T>();
    final observer = Observer<T>(
      next: (value) {
        completer.complete(value);
        disposable.dispose();
      },
      error: (error, stackTrace) {
        completer.completeError(error, stackTrace);
        disposable.dispose();
      },
      complete: () {
        completer.completeError(TooFewError());
        disposable.dispose();
      },
    );
    disposable.add(observer);
    disposable.add(subscribe(observer));
    return completer.future;
  }
}
