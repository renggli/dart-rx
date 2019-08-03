library rx.operators.tap;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Perform a side effect for every emission on the source.
Map1<Observable<T>, Observable<T>> tap<T>(Observer<T> observer) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_TapSubscriber<T>(subscriber, observer)));

class _TapSubscriber<T> extends Subscriber<T> {
  final Observer<T> observer;

  _TapSubscriber(Observer<T> destination, this.observer) : super(destination);

  @override
  void onNext(T value) {
    try {
      observer.next(value);
    } catch (error, stackTrace) {
      doError(error, stackTrace);
      return;
    }
    doNext(value);
  }

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    try {
      observer.error(error, stackTrace);
    } catch (error, stackTrace) {
      doError(error, stackTrace);
      return;
    }
    doError(error, stackTrace);
  }

  @override
  void onComplete() {
    try {
      observer.complete();
    } catch (error, stackTrace) {
      doError(error, stackTrace);
      return;
    }
    doComplete();
  }
}
