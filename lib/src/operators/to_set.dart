library rx.operators.to_set;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

typedef SetConstructor<T> = Set<T> Function();

Set<T> defaultSetConstructor<T>() => <T>{};

/// Returns an [Iterable] from an observable sequence.
Operator<T, Set<T>> toSet<T>(
        [SetConstructor<T> setConstructor = defaultSetConstructor]) =>
    _ToSetOperator(setConstructor);

class _ToSetOperator<T> implements Operator<T, T> {
  final SetConstructor<T> setConstructor;

  _ToSetOperator(this.setConstructor);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_ToSetSubscriber(destination, setConstructor()));
}

class _ToSetSubscriber<T> extends Subscriber<T> {
  final Set<T> set;

  _ToSetSubscriber(Observer<T> destination, this.set) : super(destination);

  @override
  void onNext(T value) => set.add(value);

  @override
  void onComplete() {
    destination.next(set);
    super.onComplete();
  }
}
