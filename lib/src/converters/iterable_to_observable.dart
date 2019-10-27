library rx.converters.iterable_to_observable;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/settings.dart';

extension IterableToObservable<T> on Iterable<T> {
  /// Converts this to an [Observable] that emits the items of an [Iterable].
  Observable<T> toObservable({Scheduler scheduler}) =>
      IterableObservable<T>(this, scheduler ?? defaultScheduler);
}

class IterableObservable<T> with Observable<T> {
  final Iterable<T> iterable;
  final Scheduler scheduler;

  IterableObservable(this.iterable, this.scheduler);

  @override
  Subscription subscribe(Observer<T> observer) {
    final iterator = iterable.iterator;
    return scheduler.scheduleIteration(() {
      final hasNext = iterator.moveNext();
      if (hasNext) {
        observer.next(iterator.current);
      } else {
        observer.complete();
      }
      return hasNext;
    });
  }
}
