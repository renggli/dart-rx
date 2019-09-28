library rx.constructors.just;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/schedulers/immediate.dart';

extension JustConstructor on Observable {
  /// An [Observable] with a single element.
  static Observable<T> just<T>(T value, {Scheduler scheduler}) =>
      JustObservable<T>(value, scheduler ?? const ImmediateScheduler());
}

class JustObservable<T> with Observable<T> {
  final T value;
  final Scheduler scheduler;

  const JustObservable(this.value, this.scheduler);

  @override
  Subscription subscribe(Observer<T> observer) => scheduler.schedule(() {
        observer.next(value);
        observer.complete();
      });
}
