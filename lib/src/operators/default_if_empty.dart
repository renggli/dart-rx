library rx.operators.default_if_empty;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Emits a given value if the source completes without emitting any value,
/// otherwise mirrors the source.
Map1<Observable<T>, Observable<T>> defaultIfEmpty<T>([T value]) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_DefaultIfEmptySubscriber<T>(subscriber, value)));

class _DefaultIfEmptySubscriber<T> extends Subscriber<T> {
  final T defaultValue;

  bool seenValue = false;

  _DefaultIfEmptySubscriber(Observer<T> destination, this.defaultValue)
      : super(destination);

  @override
  void onNext(T value) {
    seenValue = true;
    doNext(value);
  }

  @override
  void onComplete() {
    if (!seenValue) {
      doNext(defaultValue);
    }
    doComplete();
  }
}
