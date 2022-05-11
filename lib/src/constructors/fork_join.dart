import 'package:more/collection.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';
import 'empty.dart';

/// Waits for all passed [Observable] to complete and then it will emit an
/// list with last values from corresponding observables.
Observable<List<T>> forkJoin<T>(List<Observable<T>> sources) => sources.isEmpty
    ? empty() as Observable<List<T>>
    : ForkJoinObservable<T>(sources);

class ForkJoinObservable<T> implements Observable<List<T>> {
  ForkJoinObservable(this.observables);

  final List<Observable<T>> observables;

  @override
  Disposable subscribe(Observer<List<T>> observer) =>
      ForkJoinSubscriber<T>(observer, observables);
}

class ForkJoinSubscriber<T> extends Subscriber<List<T>>
    implements InnerEvents<T, int> {
  ForkJoinSubscriber(
      Observer<List<T>> super.observer, List<Observable<T>> observables)
      : hasValue = BitList.filled(observables.length, false),
        values = List.filled(observables.length, null, growable: false) {
    for (var i = 0; i < observables.length; i++) {
      add(InnerObserver<T, int>(this, observables[i], i));
    }
  }

  final List<bool> hasValue;
  final List<T?> values;
  int emitted = 0;
  int completed = 0;

  @override
  void notifyNext(Disposable disposable, int index, T object) {
    if (!hasValue[index]) {
      hasValue[index] = true;
      emitted++;
    }
    values[index] = object;
  }

  @override
  void notifyError(Disposable disposable, int index, Object error,
          StackTrace stackTrace) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, int index) {
    completed++;
    if (values.length == completed || !hasValue[index]) {
      if (values.length == emitted) {
        doNext(values.cast<T>().toList(growable: false));
      }
      doComplete();
    }
  }
}
