library rx.operators.to_list;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

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
  Subscription subscribe(Observer<List<T>> observer) =>
      delegate.subscribe(ToListSubscriber<T>(observer,
          listConstructor != null ? listConstructor() : <T>[]));
}

class ToListSubscriber<T> extends Subscriber<T> {
  final List<T> list;

  ToListSubscriber(Observer<List<T>> observer, this.list)
      : super(observer);

  @override
  void onNext(T value) => list.add(value);

  @override
  void onComplete() {
    doNext(list);
    doComplete();
  }
}
