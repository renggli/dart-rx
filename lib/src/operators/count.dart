library rx.operators.count;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

extension CountOperator<T> on Observable<T> {
  /// Counts the number of emissions and emits that number on completion.
  Observable<int> count() => CountObservable<T>(this);
}

class CountObservable<T> extends Observable<int> {
  final Observable<T> delegate;

  CountObservable(this.delegate);

  @override
  Subscription subscribe(Observer<int> observer) =>
      delegate.subscribe(CountSubscriber<T>(observer));
}

class CountSubscriber<T> extends Subscriber<T> {
  int count = 0;

  CountSubscriber(Observer<int> observer) : super(observer);

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
