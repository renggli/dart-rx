import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension ReduceOperator<T> on Observable<T> {
  /// Combines a sequence of values by repeatedly applying [transform].
  Observable<T> reduce(Map2<T, T, T> transform) =>
      ReduceObservable<T>(this, transform);
}

class ReduceObservable<T> implements Observable<T> {
  ReduceObservable(this.delegate, this.transform);

  final Observable<T> delegate;
  final Map2<T, T, T> transform;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = ReduceSubscriber<T>(observer, transform);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ReduceSubscriber<T> extends Subscriber<T> {
  ReduceSubscriber(Observer<T> super.destination, this.transform);

  final Map2<T, T, T> transform;
  bool hasSeed = false;
  late T seed;

  @override
  void onNext(T value) {
    if (hasSeed) {
      final transformEvent = Event.map2(transform, seed, value);
      if (transformEvent.isError) {
        doError(transformEvent.error, transformEvent.stackTrace);
      } else {
        seed = transformEvent.value;
      }
    } else {
      seed = value;
      hasSeed = true;
    }
    doNext(seed);
  }
}
