library rx.converters.iterable_to_observable;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/scheduler.dart';
import '../disposables/disposable.dart';
import '../schedulers/settings.dart';

extension IterableToObservable<T> on Iterable<T> {
  /// Returns an [Observable] that emits the elements of this [Iterable].
  Observable<T> toObservable({Scheduler scheduler}) =>
      IterableObservable<T>(this, scheduler ?? defaultScheduler);
}

class IterableObservable<T> with Observable<T> {
  final Iterable<T> iterable;
  final Scheduler scheduler;

  IterableObservable(this.iterable, this.scheduler);

  @override
  Disposable subscribe(Observer<T> observer) {
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
