library rx.constructors.throw_error;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

/// An [Observable] that emits no items and immediately throws an error.
Observable<T> throwError<T>(Object error, [StackTrace stackTrace]) =>
    _ThrowErrorObservable<T>(error, stackTrace);

class _ThrowErrorObservable<T> with Observable<T> {
  final Object error;
  final StackTrace stackTrace;

  const _ThrowErrorObservable(this.error, this.stackTrace);

  @override
  Subscription subscribe(Observer observer) {
    observer.error(error, stackTrace);
    return const InactiveSubscription();
  }
}
