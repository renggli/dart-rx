library rx.constructors.never;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscription.dart';

/// An [Observable] that emits no items and never completes.
Observable<T> never<T>() => NeverObservable<T>();

class NeverObservable<T> with Observable<T> {
  const NeverObservable();

  @override
  Subscription subscribe(Observer<void> observer) => Subscription.empty();
}
