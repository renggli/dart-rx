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

class FinalizeObservable<T> with Observable<T> {
  FinalizeObservable(this.delegate, this.finalize);

  final Observable<T> delegate;
  final CompleteCallback finalize;

  @override
  Disposable subscribe(Observer<T> observer) => CompositeDisposable([
        ActionDisposable(finalize),
        delegate.subscribe(observer),
      ]);
}
