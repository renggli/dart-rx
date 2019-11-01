library rx.operators.ignore_elements;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

extension IgnoreElementsOperator<T> on Observable<T> {
  /// Ignores all items emitted by the source and only passes calls to
  /// `complete` or `error`.
  Observable<T> ignoreElements() => IgnoreElementsObservable<T>(this);
}

class IgnoreElementsObservable<T> extends Observable<T> {
  final Observable<T> delegate;

  IgnoreElementsObservable(this.delegate);

  @override
  Subscription subscribe(Observer<T> observer) {
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
