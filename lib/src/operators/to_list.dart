library rx.operators.to_list;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

extension ToListOperator<T> on Observable<T> {
  /// Returns a [List] from an observable sequence.
  Observable<List<T>> toList([Map0<List<T>> listConstructor]) =>
      ToListObservable<T>(this, listConstructor);
}

class ToListObservable<T> extends Observable<List<T>> {
  final Observable<T> delegate;
  final Map0<List<T>> listConstructor;

  ToListObservable(this.delegate, this.listConstructor);

  @override
  Disposable subscribe(Observer<List<T>> observer) {
    final subscriber = ToListSubscriber<T>(
        observer, listConstructor != null ? listConstructor() : <T>[]);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ToListSubscriber<T> extends Subscriber<T> {
  final List<T> list;

  ToListSubscriber(Observer<List<T>> observer, this.list) : super(observer);

  @override
  void onNext(T value) => list.add(value);

  @override
  void onComplete() {
    doNext(list);
    doComplete();
  }
}
