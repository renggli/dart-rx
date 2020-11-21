library rx.constructors.just;

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../schedulers/immediate.dart';
import '../schedulers/scheduler.dart';

/// An [Observable] with a single element.
Observable<T> just<T>(T value, {Scheduler? scheduler}) =>
    JustObservable<T>(value, scheduler ?? const ImmediateScheduler());

class JustObservable<T> with Observable<T> {
  final T value;
  final Scheduler scheduler;

  const JustObservable(this.value, this.scheduler);

  @override
  Disposable subscribe(Observer<T> observer) => scheduler.schedule(() {
        observer.next(value);
        observer.complete();
      });
}
