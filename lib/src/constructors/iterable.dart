library rx.constructors.iterable;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';

/// An [Observable] that emits the items of an [Iterable].
Observable<T> fromIterable<T>(Iterable<T> iterable,
        {Scheduler scheduler = const DefaultScheduler()}) =>
    _IterableObservable<T>(iterable, scheduler);

class _IterableObservable<T> with Observable<T> {
  final Iterable<T> iterable;
  final Scheduler scheduler;

  const _IterableObservable(this.iterable, this.scheduler);

  @override
  Subscription subscribe(Observer<T> observer) {
    final iterator = iterable.iterator;
    return scheduler.scheduleIteration(() {
      if (iterator.moveNext()) {
        observer.next(iterator.current);
        return true;
      } else {
        observer.complete();
        return false;
      }
    });
  }
}
