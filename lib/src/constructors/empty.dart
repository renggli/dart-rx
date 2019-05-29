library rx.constructors.empty;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

/// An [Observable] that emits no items and immediately completes.
Observable<T> empty<T>() => _EmptyObservable<T>();

class _EmptyObservable<T> with Observable<T> {
  const _EmptyObservable();

  @override
  Subscription subscribe(Observer<void> observer) {
    observer.complete();
    return const InactiveSubscription();
  }
}
