import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension MapOperator<T> on Observable<T> {
  /// Applies the given projection function `transform` to each value emitted by
  /// this [Observable], and emits the resulting value.
  Observable<R> map<R>(Map1<T, R> transform) =>
      MapObservable<T, R>(this, transform);

  /// Emits a constant `value` for each value emitted by this [Observable].
  Observable<R> mapTo<R>(R value) =>
      MapObservable<T, R>(this, constantFunction1(value));
}

class MapObservable<T, R> implements Observable<R> {
  MapObservable(this.delegate, this.transform);

  final Observable<T> delegate;
  final Map1<T, R> transform;

  @override
  Disposable subscribe(Observer<R> observer) {
    final subscriber = MapSubscriber<T, R>(observer, transform);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class MapSubscriber<T, R> extends Subscriber<T> {
  MapSubscriber(Observer<R> super.observer, this.transform);

  final Map1<T, R> transform;

  @override
  void onNext(T value) {
    final transformEvent = Event.map1(transform, value);
    if (transformEvent.isError) {
      doError(transformEvent.error, transformEvent.stackTrace);
    } else {
      doNext(transformEvent.value);
    }
  }
}
