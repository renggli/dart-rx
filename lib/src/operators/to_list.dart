import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension ToListOperator<T> on Observable<T> {
  /// Returns a [List] from an observable sequence.
  Observable<List<T>> toList([Map0<List<T>>? constructor]) =>
      ToListObservable<T>(this, constructor ?? () => <T>[]);
}

class ToListObservable<T> implements Observable<List<T>> {
  ToListObservable(this.delegate, this.constructor);

  final Observable<T> delegate;
  final Map0<List<T>> constructor;

  @override
  Disposable subscribe(Observer<List<T>> observer) {
    final subscriber = ToListSubscriber<T>(observer, constructor());
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ToListSubscriber<T> extends Subscriber<T> {
  ToListSubscriber(Observer<List<T>> super.observer, this.list);

  final List<T> list;

  @override
  void onNext(T value) => list.add(value);

  @override
  void onComplete() {
    doNext(list);
    doComplete();
  }
}
