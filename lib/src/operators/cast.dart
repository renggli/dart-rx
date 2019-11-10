library rx.operators.cast;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../core/subscription.dart';

extension CastOperator<T> on Observable<T> {
  /// Casts all values from a source observable to [R].
  Observable<R> cast<R>() => CastObservable<T, R>(this);
}

class CastObservable<T, R> extends Observable<R> {
  final Observable<T> delegate;

  CastObservable(this.delegate);

  @override
  Subscription subscribe(Observer<R> observer) {
    final subscriber = CastSubscriber<T, R>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class CastSubscriber<T, R> extends Subscriber<T> {
  CastSubscriber(Observer<R> observer) : super(observer);

  @override
  void onNext(T value) {
    doNext(value as R);
  }
}
