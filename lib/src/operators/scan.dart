library rx.operators.scan;

import '../core/events.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../core/subscription.dart';
import '../shared/functions.dart';

extension ScanOperator<T> on Observable<T> {
  /// Combines a sequence of values by repeatedly applying [transform].
  Observable<T> reduce(Map2<T, T, T> transform) =>
      ScanObservable<T, T>(this, transform, false, null);

  /// Combines a sequence of values by repeatedly applying [transform], starting
  /// with the provided [initialValue].
  Observable<R> fold<R>(R initialValue, Map2<R, T, R> transform) =>
      ScanObservable<T, R>(this, transform, true, initialValue);
}

class ScanObservable<T, R> extends Observable<R> {
  final Observable<T> delegate;
  final Map2<R, T, R> transform;
  final bool hasSeed;
  final R seedValue;

  ScanObservable(this.delegate, this.transform, this.hasSeed, this.seedValue);

  @override
  Subscription subscribe(Observer<R> observer) {
    final subscriber =
        ScanSubscriber<T, R>(observer, transform, hasSeed, seedValue);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ScanSubscriber<T, R> extends Subscriber<T> {
  final Map2<R, T, R> transform;
  bool hasSeed;
  R seedValue;

  ScanSubscriber(
      Observer<R> destination, this.transform, this.hasSeed, this.seedValue)
      : super(destination);

  @override
  void onNext(T value) {
    if (hasSeed) {
      final transformEvent = Event.map2(transform, seedValue, value);
      if (transformEvent is ErrorEvent) {
        doError(transformEvent.error, transformEvent.stackTrace);
      } else {
        seedValue = transformEvent.value;
      }
    } else {
      seedValue = value as R;
      hasSeed = true;
    }
    doNext(seedValue);
  }
}
