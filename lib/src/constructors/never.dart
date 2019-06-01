library rx.constructors.never;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

/// An [Observable] that emits no items and never completes.
Observable<T> never<T>() => _NeverObservable<T>();

class _NeverObservable<T> with Observable<T> {
  const _NeverObservable();

  @override
  Subscription subscribe(Observer<void> observer) => Subscription.closed();
}
