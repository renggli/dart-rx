library rx.operators.to_list;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef ListConstructor<T> = List<T> Function();

/// Returns a [List] from an observable sequence.
Operator<T, List<T>> toList<T>([ListConstructor<T> listConstructor]) =>
    (subscriber, source) => source.subscribe(_ToListSubscriber(
        subscriber, listConstructor != null ? listConstructor : <T>[]));

class _ToListSubscriber<T> extends Subscriber<T> {
  final List<T> list;

  _ToListSubscriber(Observer<List<T>> destination, this.list)
      : super(destination);

  @override
  void onNext(T value) => list.add(value);

  @override
  void onComplete() {
    doNext(list);
    doComplete();
  }
}
