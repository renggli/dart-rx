library rx.operators.default_if_empty;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

extension DefaultIfEmptyOperator<T> on Observable<T> {
  /// Emits a given value if the source completes without emitting any value,
  /// otherwise mirrors the source.
  Observable<T> defaultIfEmpty([T value]) =>
      DefaultIfEmptyObservable<T>(this, value);
}

class DefaultIfEmptyObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final T defaultValue;

  DefaultIfEmptyObservable(this.delegate, this.defaultValue);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = DefaultIfEmptySubscriber<T>(observer, defaultValue);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class DefaultIfEmptySubscriber<T> extends Subscriber<T> {
  final T defaultValue;

  bool seenValue = false;

  DefaultIfEmptySubscriber(Observer<T> observer, this.defaultValue)
      : super(observer);

  @override
  void onNext(T value) {
    seenValue = true;
    doNext(value);
  }

  @override
  void onComplete() {
    if (!seenValue) {
      doNext(defaultValue);
    }
    doComplete();
  }
}
