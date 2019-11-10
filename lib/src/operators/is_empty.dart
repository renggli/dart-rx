library rx.operators.is_empty;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../core/subscription.dart';

extension IsEmptyOperator<T> on Observable<T> {
  /// Emits `false` if the input observable emits any values, or emits `true` if
  /// the input observable completes without emitting any values.
  Observable<bool> isEmpty() => IsEmptyObservable<T>(this);
}

class IsEmptyObservable<T> extends Observable<bool> {
  final Observable<T> delegate;

  IsEmptyObservable(this.delegate);

  @override
  Subscription subscribe(Observer<bool> observer) {
    final subscriber = IsEmptySubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class IsEmptySubscriber<T> extends Subscriber<T> {
  IsEmptySubscriber(Observer<bool> observer) : super(observer);

  @override
  void onNext(T value) {
    doNext(false);
    doComplete();
  }

  @override
  void onComplete() {
    doNext(true);
    doComplete();
  }
}
