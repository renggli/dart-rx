import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension CastOperator<T> on Observable<T> {
  /// Casts the values from this [Observable] to [R].
  ///
  /// For example:
  ///
  /// ```dart
  /// just<Object>(1).cast<int>().subscribe(Observer(next: print)); // prints 1
  /// ```
  Observable<R> cast<R>() => CastObservable<T, R>(this);
}

class CastObservable<T, R> implements Observable<R> {
  CastObservable(this.delegate);

  final Observable<T> delegate;

  @override
  Disposable subscribe(Observer<R> observer) {
    final subscriber = CastSubscriber<T, R>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class CastSubscriber<T, R> extends Subscriber<T> {
  CastSubscriber(Observer<R> super.observer);

  @override
  void onNext(T value) => doNext(value as R);
}
