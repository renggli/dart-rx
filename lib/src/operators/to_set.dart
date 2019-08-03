library rx.operators.to_set;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Returns a [Set] from an observable sequence.
Map1<Observable<T>, Observable<Set<T>>> toSet<T>(
        [Map0<Set<T>> setConstructor]) =>
    (source) => source.lift((source, subscriber) => source.subscribe(
        _ToSetSubscriber<T>(
            subscriber, setConstructor != null ? setConstructor() : <T>{})));

class _ToSetSubscriber<T> extends Subscriber<T> {
  final Set<T> set;

  _ToSetSubscriber(Observer<Set<T>> destination, this.set) : super(destination);

  @override
  void onNext(T value) => set.add(value);

  @override
  void onComplete() {
    doNext(set);
    doComplete();
  }
}
