library rx.constructors.empty;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/scheduler.dart';
import '../core/subscription.dart';
import '../schedulers/immediate.dart';

/// An [Observable] that emits no items and immediately completes.
Observable<T> empty<T>({Scheduler scheduler}) =>
    EmptyObservable<T>(scheduler ?? const ImmediateScheduler());

class EmptyObservable<T> with Observable<T> {
  final Scheduler scheduler;

  const EmptyObservable(this.scheduler);

  @override
  Subscription subscribe(Observer<void> observer) =>
      scheduler.schedule(() => observer.complete());
}
