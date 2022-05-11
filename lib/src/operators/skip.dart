import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension SkipOperator<T> on Observable<T> {
  /// Skips over the first [count] values before starting to emit.
  Observable<T> skip([int count = 1]) => SkipObservable<T>(this, count);
}

class SkipObservable<T> implements Observable<T> {
  SkipObservable(this.delegate, this.count);

  final Observable<T> delegate;
  final int count;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = SkipSubscriber<T>(observer, count);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SkipSubscriber<T> extends Subscriber<T> {
  SkipSubscriber(Observer<T> super.observer, this.count);

  int count;

  @override
  void onNext(T value) {
    if (count > 0) {
      count--;
    } else {
      doNext(value);
    }
  }
}
