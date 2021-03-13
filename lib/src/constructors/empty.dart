import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../schedulers/immediate.dart';
import '../schedulers/scheduler.dart';

/// An [Observable] that emits no items and immediately completes.
Observable<Never> empty({Scheduler? scheduler}) =>
    EmptyObservable(scheduler ?? const ImmediateScheduler());

class EmptyObservable with Observable<Never> {
  final Scheduler scheduler;

  const EmptyObservable(this.scheduler);

  @override
  Disposable subscribe(Observer<void> observer) =>
      scheduler.schedule(() => observer.complete());
}
