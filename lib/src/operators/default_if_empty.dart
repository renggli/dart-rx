import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension DefaultIfEmptyOperator<T> on Observable<T> {
  /// Emits a given value if this [Observable] completes without emitting any
  /// value, otherwise mirrors the source.
  Observable<T> defaultIfEmpty(T value) =>
      DefaultIfEmptyObservable<T>(this, value);
}

class DefaultIfEmptyObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final T defaultValue;

  DefaultIfEmptyObservable(this.delegate, this.defaultValue);

  @override
  Disposable subscribe(Observer<T> observer) {
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
