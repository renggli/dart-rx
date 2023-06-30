import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/action.dart';
import '../disposables/composite.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

extension FinalizeOperator<T> on Observable<T> {
  /// Return an [Observable] that mirrors this [Observable], but will call
  /// a specified function when the source terminates on completion or error.
  Observable<T> finalize(CompleteCallback finalize) =>
      FinalizeObservable<T>(this, finalize);
}

class FinalizeObservable<T> implements Observable<T> {
  FinalizeObservable(this.delegate, CompleteCallback finalize)
      : finalize = _once(finalize);

  final Observable<T> delegate;
  final CompleteCallback finalize;

  @override
  Disposable subscribe(Observer<T> observer) => CompositeDisposable([
        ActionDisposable(finalize),
        delegate.subscribe(Observer(
            next: observer.next,
            error: (error, stackTrace) {
              try {
                observer.error(error, stackTrace);
              } finally {
                finalize();
              }
            },
            complete: () {
              try {
                observer.complete();
              } finally {
                finalize();
              }
            })),
      ]);
}

CompleteCallback _once(CompleteCallback callback) {
  var called = false;
  return () {
    if (!called) {
      called = true;
      callback();
    }
  };
}
