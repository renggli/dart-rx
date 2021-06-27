import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension ToSetOperator<T> on Observable<T> {
  /// Returns a [Set] from an observable sequence.
  Observable<Set<T>> toSet([Map0<Set<T>>? constructor]) =>
      ToSetObservable<T>(this, constructor ?? () => <T>{});
}

class ToSetObservable<T> with Observable<Set<T>> {
  final Observable<T> delegate;
  final Map0<Set<T>> constructor;

  ToSetObservable(this.delegate, this.constructor);

  @override
  Disposable subscribe(Observer<Set<T>> observer) {
    final subscriber = ToSetSubscriber<T>(observer, constructor());
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
