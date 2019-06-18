library rx.operators.combine_latest;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Combines multiple Observables to create an Observable whose values are
/// calculated from the latest values of each of its input Observables.
Operator<Observable<T>, List<T>> combineLatest<T>() => (subscriber, source) =>
    source.subscribe(_CombineLatestSubscriber(subscriber));

class _CombineLatestSubscriber<T> extends Subscriber<Observable<T>> {
  final List<Observable<T>> observables = [];
  final List<bool> hasValues = [];
  final List<T> values = [];

  int active;
  int pending;

  _CombineLatestSubscriber(Observer<List<T>> destination) : super(destination);

  @override
  void onNext(Observable<T> observable) {
    observables.add(observable);
    hasValues.add(false);
    values.add(null);
  }

  @override
  void onComplete() {
    if (values.isEmpty) {
      doComplete();
    } else {
      active = observables.length;
      pending = observables.length;
      for (var i = 0; i < observables.length; i++) {
        add(observables[i].subscribe(Observer(
          next: (value) => notifyNext(i, value),
          error: (error, [stackTrace]) => notifyError(i, error, stackTrace),
          complete: () => notifyComplete(i),
        )));
      }
    }
  }

  void notifyNext(int index, T value) {
    values[index] = value;
    if (!hasValues[index]) {
      pending--;
      hasValues[index] = true;
    }
    if (pending == 0) {
      doNext(List<T>.of(values, growable: false));
    }
  }

  void notifyError(int index, Object error, StackTrace stackTrace) {
    doError(error, stackTrace);
  }

  void notifyComplete(int index) {
    active--;
    if (active == 0) {
      doComplete();
    }
  }
}
