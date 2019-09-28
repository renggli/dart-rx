library rx.constructors.throw_error;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/immediate.dart';

extension ThrowErrorConstructor on Observable {
  /// An [Observable] that emits no items and immediately throws an error.
  static Observable<T> throwError<T>(Object error,
          {StackTrace stackTrace, Scheduler scheduler}) =>
      ThrowErrorObservable<T>(
          error, stackTrace, scheduler ?? const ImmediateScheduler());
}

class ThrowErrorObservable<T> with Observable<T> {
  final Object error;
  final StackTrace stackTrace;
  final Scheduler scheduler;

  const ThrowErrorObservable(this.error, this.stackTrace, this.scheduler);

  @override
  Subscription subscribe(Observer observer) =>
      scheduler.schedule(() => observer.error(error, stackTrace));
}
