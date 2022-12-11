import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../schedulers/immediate.dart';
import '../schedulers/scheduler.dart';

/// An [Observable] that emits no items and immediately throws an error.
Observable<Never> throwError(Object error,
        {StackTrace? stackTrace, Scheduler? scheduler}) =>
    ThrowErrorObservable(error, stackTrace ?? StackTrace.current,
        scheduler ?? const ImmediateScheduler());

class ThrowErrorObservable implements Observable<Never> {
  const ThrowErrorObservable(this.error, this.stackTrace, this.scheduler);

  final Object error;
  final StackTrace stackTrace;
  final Scheduler scheduler;

  @override
  Disposable subscribe(Observer<dynamic> observer) =>
      scheduler.schedule(() => observer.error(error, stackTrace));
}
