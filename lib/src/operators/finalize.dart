library rx.operators.finalize;

import '../../subscriptions.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscription.dart';
import '../shared/functions.dart';

extension FinalizeOperator<T> on Observable<T> {
  /// Return an [Observable] that mirrors the source [Observable], but will call
  /// a specified function when the source terminates on complete or error.
  Observable<T> finalize(CompleteCallback finalize) =>
      FinalizeObservable<T>(this, finalize);
}

class FinalizeObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final CompleteCallback finalize;

  FinalizeObservable(this.delegate, this.finalize);

  @override
  Subscription subscribe(Observer<T> observer) => Subscription.composite([
        Subscription.of(finalize),
        delegate.subscribe(observer),
      ]);
}
