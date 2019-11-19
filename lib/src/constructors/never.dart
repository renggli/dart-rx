library rx.constructors.never;

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../disposables/disposed.dart';

/// An [Observable] that emits no items and never completes.
Observable<T> never<T>() => NeverObservable<T>();

class NeverObservable<T> with Observable<T> {
  const NeverObservable();

  @override
  Disposable subscribe(Observer<T> observer) => const DisposedDisposable();
}
