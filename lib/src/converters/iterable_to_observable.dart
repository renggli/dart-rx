import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../schedulers/scheduler.dart';
import '../schedulers/settings.dart';

extension IterableToObservable<T> on Iterable<T> {
  /// Returns an [Observable] that emits the elements of this [Iterable].
  Observable<T> toObservable({Scheduler? scheduler}) =>
      IterableObservable<T>(this, scheduler ?? defaultScheduler);
}

class IterableObservable<T> implements Observable<T> {
  IterableObservable(this.iterable, this.scheduler);

  final Iterable<T> iterable;
  final Scheduler scheduler;

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
