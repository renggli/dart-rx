library rx.operators.skip;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension SkipOperator<T> on Observable<T> {
  /// Skips over the first [count] values before starting to emit.
  Observable<T> skip([int count = 1]) => SkipObservable<T>(this, count);
}

class SkipObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final int count;

  SkipObservable(this.delegate, this.count);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = SkipSubscriber<T>(observer, count);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SkipSubscriber<T> extends Subscriber<T> {
  int count;

  SkipSubscriber(Observer<T> observer, this.count) : super(observer);

  @override
  void onNext(T value) {
    if (count > 0) {
      count--;
    } else {
      doNext(value);
    }
  }
}
