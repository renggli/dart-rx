import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension IgnoreElementsOperator<T> on Observable<T> {
  /// Ignores all items emitted by this [Observable] and only passes errors
  /// and completion events.
  Observable<T> ignoreElements() => IgnoreElementsObservable<T>(this);
}

class IgnoreElementsObservable<T> with Observable<T> {
  final Observable<T> delegate;

  IgnoreElementsObservable(this.delegate);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = IgnoreElementsSubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class IgnoreElementsSubscriber<T> extends Subscriber<T> {
  IgnoreElementsSubscriber(Observer<T> observer) : super(observer);

  @override
  void onNext(T value) {}
}
