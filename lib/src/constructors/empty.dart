import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../schedulers/immediate.dart';
import '../schedulers/scheduler.dart';

/// An [Observable] that emits no items and immediately completes.
///
/// For example:
///
/// ```dart
/// empty().subscribe(Observer(
///   next: print,
///   complete: () => print('done'),
/// )); // prints 'done'
/// ```
Observable<Never> empty({Scheduler? scheduler}) =>
    EmptyObservable(scheduler ?? const ImmediateScheduler());

class EmptyObservable implements Observable<Never> {
  const EmptyObservable(this.scheduler);

  final Scheduler scheduler;

  @override
  Disposable subscribe(Observer<void> observer) =>
      scheduler.schedule(observer.complete);
}
