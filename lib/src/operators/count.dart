import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension CountOperator<T> on Observable<T> {
  /// Counts the number of emissions of this [Observable] and emits that number
  /// on completion.
  ///
  /// For example:
  ///
  /// ```dart
  /// [1, 2, 3].toObservable()
  ///     .count()
  ///     .subscribe(Observer(next: print)); // prints 3
  /// ```
  Observable<int> count() => CountObservable<T>(this);
}

class CountObservable<T> implements Observable<int> {
  CountObservable(this.delegate);

  final Observable<T> delegate;

  @override
  Disposable subscribe(Observer<int> observer) {
    final subscriber = CountSubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class CountSubscriber<T> extends Subscriber<T> {
  CountSubscriber(Observer<int> super.observer);

  int count = 0;

  @override
  void onNext(T value) {
    count++;
  }

  @override
  void onComplete() {
    doNext(count);
    doComplete();
  }
}
