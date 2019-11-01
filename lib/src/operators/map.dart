library rx.operators.map;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension MapOperator<T> on Observable<T> {
  /// Applies a given project function to each value emitted by the source
  /// Observable, and emits the resulting values as an Observable.
  Observable<R> map<R>(Map1<T, R> transform) =>
      MapObservable<T, R>(this, transform);

  /// Applies a given project function to each value emitted by the source
  /// Observable, and emits the resulting values as an Observable.
  Observable<R> mapTo<R>(R value) =>
      MapObservable<T, R>(this, constantFunction1(value));
}

class MapObservable<T, R> extends Observable<R> {
  final Observable<T> delegate;
  final Map1<T, R> transform;

  MapObservable(this.delegate, this.transform);

  @override
  Subscription subscribe(Observer<R> observer) {
    final subscriber = MapSubscriber<T, R>(observer, transform);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class MapSubscriber<T, R> extends Subscriber<T> {
  final Map1<T, R> transform;

  MapSubscriber(Observer<R> observer, this.transform) : super(observer);

  @override
  void onNext(T value) {
    final transformEvent = Event.map1(transform, value);
    if (transformEvent is ErrorEvent) {
      doError(transformEvent.error, transformEvent.stackTrace);
    } else {
      doNext(transformEvent.value);
    }
  }
}
