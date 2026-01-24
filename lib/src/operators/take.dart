import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension TakeOperator<T> on Observable<T> {
  /// Emits the first [count] values before completing.
  ///
  /// For example:
  ///
  /// ```dart
  /// [1, 2, 3].toObservable()
  ///     .take(2)
  ///     .subscribe(Observer(next: print)); // prints 1, 2
  /// ```
  Observable<T> take([int count = 1]) => TakeObservable<T>(this, count);
}

class TakeObservable<T> implements Observable<T> {
  TakeObservable(this.delegate, this.count);

  final Observable<T> delegate;
  final int count;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = TakeSubscriber<T>(observer, count);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TakeSubscriber<T> extends Subscriber<T> {
  TakeSubscriber(Observer<T> super.observer, this.count);

  int count;

  @override
  void onNext(T value) {
    doNext(value);
    if (--count <= 0) {
      doComplete();
    }
  }
}
