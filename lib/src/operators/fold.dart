import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension FoldOperator<T> on Observable<T> {
  /// Combines a sequence of values by repeatedly applying [transform], starting
  /// with the provided [initialValue].
  Observable<R> fold<R>(R initialValue, Map2<R, T, R> transform) =>
      FoldObservable<T, R>(this, transform, initialValue);
}

class FoldObservable<T, R> implements Observable<R> {
  FoldObservable(this.delegate, this.transform, this.initialValue);

  final Observable<T> delegate;
  final Map2<R, T, R> transform;
  final R initialValue;

  @override
  Disposable subscribe(Observer<R> observer) {
    final subscriber = FoldSubscriber<T, R>(observer, transform, initialValue);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class FoldSubscriber<T, R> extends Subscriber<T> {
  FoldSubscriber(Observer<R> super.destination, this.transform, this.seed);

  final Map2<R, T, R> transform;
  R seed;

  @override
  void onNext(T value) {
    final transformEvent = Event.map2(transform, seed, value);
    if (transformEvent.isError) {
      doError(transformEvent.error, transformEvent.stackTrace);
    } else {
      seed = transformEvent.value;
    }
    doNext(seed);
  }
}
