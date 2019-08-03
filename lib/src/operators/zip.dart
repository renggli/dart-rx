library rx.operators.zip;

import 'dart:collection';

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';

/// Combines multiple Observables to create an Observable whose values are
/// calculated from the next value of each of its input Observables.
OperatorFunction<Observable<T>, List<T>> zip<T>() => (source) => source.lift(
    (source, subscriber) => source.subscribe(_ZipSubscriber<T>(subscriber)));

class _ZipSubscriber<T> extends Subscriber<Observable<T>>
    implements InnerEvents<T, int> {
  final List<Observable<T>> observables = [];
  final List<ListQueue<T>> pending = [];

  _ZipSubscriber(Observer<List<T>> destination) : super(destination);

  @override
  void onNext(Observable<T> observable) {
    observables.add(observable);
    pending.add(ListQueue());
  }

  @override
  void onComplete() {
    if (observables.isEmpty) {
      doComplete();
    } else {
      for (var i = 0; i < observables.length; i++) {
        add(InnerObserver(observables[i], this, i));
      }
    }
  }

  @override
  void notifyNext(Subscription subscription, int index, T value) {
    pending[index].addLast(value);
    if (pending.every((each) => each.isNotEmpty)) {
      doNext(List.generate(pending.length, (i) => pending[i].removeFirst(),
          growable: false));
    }
  }

  @override
  void notifyError(Subscription subscription, int index, Object error,
      [StackTrace stackTrace]) {
    doError(error, stackTrace);
  }

  @override
  void notifyComplete(Subscription subscription, int index) {
    if (pending[index].isEmpty) {
      doComplete();
    }
  }
}
