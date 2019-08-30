library rx.operators.to_set;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension ToSetOperator<T> on Observable<T> {
  /// Returns a [Set] from an observable sequence.
  Observable<Set<T>> toSet([Map0<Set<T>> setConstructor]) =>
      ToSetObservable<T>(this, setConstructor);
}

class ToSetObservable<T> extends Observable<Set<T>> {
  final Observable<T> delegate;
  final Map0<Set<T>> setConstructor;

  ToSetObservable(this.delegate, this.setConstructor);

  @override
  Subscription subscribe(Observer<Set<T>> observer) =>
      delegate.subscribe(ToSetSubscriber<T>(observer,
          setConstructor != null ? setConstructor() : <T>{}));
}

class ToSetSubscriber<T> extends Subscriber<T> {
  final Set<T> set;

  ToSetSubscriber(Observer<Set<T>> observer, this.set)
      : super(observer);

  @override
  void onNext(T value) => set.add(value);

  @override
  void onComplete() {
    doNext(set);
    doComplete();
  }
}
