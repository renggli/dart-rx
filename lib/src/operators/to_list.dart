library rx.operators.to_list;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Returns a [List] from an observable sequence.
OperatorFunction<T, List<T>> toList<T>([Map0<List<T>> listConstructor]) =>
    (source) => source.lift((source, subscriber) => source.subscribe(
        _ToListSubscriber<T>(
            subscriber, listConstructor != null ? listConstructor() : <T>[])));

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
