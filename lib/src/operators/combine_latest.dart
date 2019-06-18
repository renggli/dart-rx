library rx.operators.combine_latest;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';

/// Combines multiple Observables to create an Observable whose values are
/// calculated from the latest values of each of its input Observables.
Operator<Observable<T>, List<T>> combineLatest<T>() => (subscriber, source) =>
    source.subscribe(_CombineLatestSubscriber(subscriber));

class _CombineLatestSubscriber<T> extends Subscriber<Observable<T>>
    implements InnerEvents<T, int> {
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
        add(InnerObserver(observables[i], this, i));
      }
    }
  }

  @override
  void notifyNext(Subscription subscription, int index, T value) {
    values[index] = value;
    if (!hasValues[index]) {
      pending--;
      hasValues[index] = true;
    }
    if (pending == 0) {
      doNext(List<T>.of(values, growable: false));
    }
  }

  @override
  void notifyError(Subscription subscription, int index, Object error,
      [StackTrace stackTrace]) {
    doError(error, stackTrace);
  }

  @override
  void notifyComplete(Subscription subscription, int index) {
    active--;
    if (active == 0) {
      doComplete();
    }
  }
}
