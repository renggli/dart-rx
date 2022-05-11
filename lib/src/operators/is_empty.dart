import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension IsEmptyOperator<T> on Observable<T> {
  /// Emits `true` if this [Observable] completes without emitting any values,
  /// otherwise emits `false`.
  Observable<bool> isEmpty() => IsEmptyObservable<T>(this);
}

class IsEmptyObservable<T> implements Observable<bool> {
  IsEmptyObservable(this.delegate);

  final Observable<T> delegate;

  @override
  Disposable subscribe(Observer<bool> observer) {
    final subscriber = IsEmptySubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class IsEmptySubscriber<T> extends Subscriber<T> {
  IsEmptySubscriber(Observer<bool> super.observer);

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
