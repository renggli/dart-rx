import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../disposables/disposed.dart';

/// An [Observable] that emits no items and never completes.
Observable<Never> never() => const NeverObservable();

class NeverObservable implements Observable<Never> {
  const NeverObservable();

  @override
  Disposable subscribe(Observer<Never> observer) => const DisposedDisposable();
}
