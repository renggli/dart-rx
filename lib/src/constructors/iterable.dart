library rx.constructors.iterable;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

/// An [Observable] that emits the items of an [Iterable].
Observable<T> fromIterable<T>(Iterable<T> iterable) =>
    _IterableObservable<T>(iterable);

class _IterableObservable<T> with Observable<T> {
  final Iterable<T> iterable;

  _IterableObservable(this.iterable);

  @override
  Subscription subscribe(Observer<T> observer) {
    iterable.forEach(observer.next);
    observer.complete();
    return const InactiveSubscription();
  }
}
