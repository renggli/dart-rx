library rx.operators.to_list;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

typedef ListConstructor<T> = List<T> Function();

List<T> defaultListConstructor<T>() => <T>[];

/// Returns a [List] from an observable sequence.
Operator<T, List<T>> toList<T>([ListConstructor<T> listConstructor]) =>
    _ToListOperator(listConstructor ?? defaultListConstructor);

class _ToListOperator<T> implements Operator<T, List<T>> {
  final ListConstructor<T> listConstructor;

  _ToListOperator(this.listConstructor);

  @override
  Subscription call(Observable<T> source, Observer<List<T>> destination) =>
      source.subscribe(_ToListSubscriber(destination, listConstructor()));
}

class _ToListSubscriber<T> extends Subscriber<T> {
  final List<T> list;

  _ToListSubscriber(Observer<List<T>> destination, this.list)
      : super(destination);

  @override
  void onNext(T value) => list.add(value);

  @override
  void onComplete() {
    destination.next(list);
    destination.complete();
  }
}
