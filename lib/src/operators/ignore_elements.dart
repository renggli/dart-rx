library rx.operators.ignore_elements;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Ignores all items emitted by the source and only passes calls to
/// `complete` or `error`.
Map1<Observable<T>, Observable<T>> ignoreElements<T>() =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_IgnoreElementsSubscriber<T>(subscriber)));

class _IgnoreElementsSubscriber<T> extends Subscriber<T> {
  _IgnoreElementsSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(T value) {}
}
