import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';
import '../shared/functions.dart';

extension ReduceOperator<T> on Observable<T> {
  /// Combines a sequence of values by repeatedly applying [transform].
  Observable<T> reduce(Map2<T, T, T> transform) =>
      ReduceObservable<T>(this, transform);
}

class ReduceObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Map2<T, T, T> transform;

  ReduceObservable(this.delegate, this.transform);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = ReduceSubscriber<T>(observer, transform);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ReduceSubscriber<T> extends Subscriber<T> {
  final Map2<T, T, T> transform;
  bool hasSeed = false;
  late T seedValue;

  ReduceSubscriber(Observer<T> destination, this.transform)
      : super(destination);

  @override
  void onNext(T value) {
    if (hasSeed) {
      final transformEvent = Event.map2(transform, seedValue, value);
      if (transformEvent.isError) {
        doError(transformEvent.error, transformEvent.stackTrace);
      } else {
        seedValue = transformEvent.value;
      }
    } else {
      seedValue = value;
      hasSeed = true;
    }
    doNext(seedValue);
  }
}
