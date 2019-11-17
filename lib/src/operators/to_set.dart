library rx.operators.to_set;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

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
  Disposable subscribe(Observer<Set<T>> observer) {
    final subscriber = ToSetSubscriber<T>(
        observer, setConstructor != null ? setConstructor() : <T>{});
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ToSetSubscriber<T> extends Subscriber<T> {
  final Set<T> set;

  ToSetSubscriber(Observer<Set<T>> observer, this.set) : super(observer);

  @override
  void onNext(T value) => set.add(value);

  @override
  void onComplete() {
    doNext(set);
    doComplete();
  }
}
