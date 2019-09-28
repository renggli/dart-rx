library rx.constructors.empty;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/immediate.dart';

extension EmptyConstructor on Observable {
  /// An [Observable] that emits no items and immediately completes.
  static Observable<T> empty<T>({Scheduler scheduler}) =>
      EmptyObservable<T>(scheduler ?? const ImmediateScheduler());
}

class EmptyObservable<T> with Observable<T> {
  final Scheduler scheduler;

  const EmptyObservable(this.scheduler);

  @override
  Subscription subscribe(Observer<void> observer) =>
      scheduler.schedule(() => observer.complete());
}
