library rx.constructors.empty;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/immediate.dart';

/// An [Observable] that emits no items and immediately completes.
Observable<T> empty<T>({Scheduler scheduler}) =>
    _EmptyObservable<T>(scheduler ?? const ImmediateScheduler());

class _EmptyObservable<T> with Observable<T> {
  final Scheduler scheduler;

  const _EmptyObservable(this.scheduler);

  @override
  Subscription subscribe(Observer<void> observer) =>
      scheduler.schedule(() => observer.complete());
}
