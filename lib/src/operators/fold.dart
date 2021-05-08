import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';
import '../shared/functions.dart';

extension FoldOperator<T> on Observable<T> {
  /// Combines a sequence of values by repeatedly applying [transform], starting
  /// with the provided [initialValue].
  Observable<R> fold<R>(R initialValue, Map2<R, T, R> transform) =>
      FoldObservable<T, R>(this, transform, initialValue);
}

class FoldObservable<T, R> with Observable<R> {
  final Observable<T> delegate;
  final Map2<R, T, R> transform;
  final R seedValue;

  FoldObservable(this.delegate, this.transform, this.seedValue);

  @override
  Disposable subscribe(Observer<R> observer) {
    final subscriber = FoldSubscriber<T, R>(observer, transform, seedValue);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class FoldSubscriber<T, R> extends Subscriber<T> {
  final Map2<R, T, R> transform;
  R seedValue;

  FoldSubscriber(Observer<R> destination, this.transform, this.seedValue)
      : super(destination);

  @override
  void onNext(T value) {
    final transformEvent = Event.map2(transform, seedValue, value);
    if (transformEvent.isError) {
      doError(transformEvent.error, transformEvent.stackTrace);
    } else {
      seedValue = transformEvent.value;
    }
    doNext(seedValue);
  }
}
