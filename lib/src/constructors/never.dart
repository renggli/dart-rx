library rx.constructors.never;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

extension NeverConstructor on Observable {
  /// An [Observable] that emits no items and never completes.
  static Observable<T> never<T>() => NeverObservable<T>();
}

class NeverObservable<T> with Observable<T> {
  const NeverObservable();

  @override
  Subscription subscribe(Observer<void> observer) => Subscription.empty();
}
