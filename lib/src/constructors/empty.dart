library rx.constructors.empty;

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../schedulers/immediate.dart';
import '../schedulers/scheduler.dart';

/// An [Observable] that emits no items and immediately completes.
Observable<T> empty<T>({Scheduler scheduler}) =>
    EmptyObservable<T>(scheduler ?? const ImmediateScheduler());

class EmptyObservable<T> with Observable<T> {
  final Scheduler scheduler;

  const EmptyObservable(this.scheduler);

  @override
  Disposable subscribe(Observer<void> observer) =>
      scheduler.schedule(() => observer.complete());
}
