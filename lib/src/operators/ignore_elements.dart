library rx.operators.ignore_elements;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension IgnoreElementsOperator<T> on Observable<T> {
  /// Ignores all items emitted by the source and only passes calls to
  /// `complete` or `error`.
  Observable<T> ignoreElements() => IgnoreElementsObservable<T>(this);
}

class IgnoreElementsObservable<T> extends Observable<T> {
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
