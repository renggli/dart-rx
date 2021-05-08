import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension TakeOperator<T> on Observable<T> {
  /// Emits the first [count] values before completing.
  Observable<T> take([int count = 1]) => TakeObservable<T>(this, count);
}

class TakeObservable<T> with Observable<T> {
  final Observable<T> delegate;
  final int count;

  TakeObservable(this.delegate, this.count);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = TakeSubscriber<T>(observer, count);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TakeSubscriber<T> extends Subscriber<T> {
  int count;

  TakeSubscriber(Observer<T> observer, this.count) : super(observer);

  @override
  void onNext(T value) {
    doNext(value);
    if (--count <= 0) {
      doComplete();
    }
  }
}
