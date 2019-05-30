library rx.operators.to_list;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

typedef ListConstructor<T> = List<T> Function();

List<T> defaultListConstructor<T>() => [];

/// Returns an [Iterable] from an observable sequence.
Operator<T, List<T>> toList<T>(
        [ListConstructor<T> listConstructor = defaultListConstructor]) =>
    _ToListOperator(listConstructor);

class _ToListOperator<T> implements Operator<T, T> {
  final ListConstructor<T> listConstructor;

  _ToListOperator(this.listConstructor);

  @override
  Subscription call(Observable<T> source, Observer<T> destination) =>
      source.subscribe(_ToListSubscriber(destination, listConstructor()));
}

class _ToListSubscriber<T> extends Subscriber<T> {
  final List<T> list;

  _ToListSubscriber(Observer<T> destination, this.list) : super(destination);

  @override
  void onNext(T value) => list.add(value);

  @override
  void onComplete() {
    destination.next(list);
    super.onComplete();
  }
}
