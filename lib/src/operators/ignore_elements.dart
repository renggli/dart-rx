import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension IgnoreElementsOperator<T> on Observable<T> {
  /// Ignores all items emitted by this [Observable] and only passes errors
  /// and completion events.
  Observable<T> ignoreElements() => IgnoreElementsObservable<T>(this);
}

class IgnoreElementsObservable<T> implements Observable<T> {
  IgnoreElementsObservable(this.delegate);

  final Observable<T> delegate;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = IgnoreElementsSubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class IgnoreElementsSubscriber<T> extends Subscriber<T> {
  IgnoreElementsSubscriber(Observer<T> super.observer);

  @override
  void onNext(T value) {}
}
