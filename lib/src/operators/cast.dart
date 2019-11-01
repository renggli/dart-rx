library rx.operators.cast;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

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
