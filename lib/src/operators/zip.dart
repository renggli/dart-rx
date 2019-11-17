library rx.operators.zip;

import 'dart:collection';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';

extension ZipOperator<T> on Observable<Observable<T>> {
  /// Combines multiple Observables to create an Observable whose values are
  /// calculated from the next value of each of its input Observables.
  Observable<List<T>> zip() => ZipObservable<T>(this);
}

class ZipObservable<T> extends Observable<List<T>> {
  final Observable<Observable<T>> delegate;

  ZipObservable(this.delegate);

  @override
  Disposable subscribe(Observer<List<T>> observer) {
    final subscriber = ZipSubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ZipSubscriber<T> extends Subscriber<Observable<T>>
    implements InnerEvents<T, int> {
  final List<Observable<T>> observables = [];
  final List<ListQueue<T>> pending = [];

  ZipSubscriber(Observer<List<T>> observer) : super(observer);

  @override
  void onNext(Observable<T> value) {
    observables.add(value);
    pending.add(ListQueue<T>());
  }

  @override
  void onComplete() {
    if (observables.isEmpty) {
      doComplete();
    } else {
      for (var i = 0; i < observables.length; i++) {
        add(InnerObserver(observables[i], this, i));
      }
    }
  }

  @override
  void notifyNext(Disposable subscription, int index, T value) {
    pending[index].addLast(value);
    if (pending.every((each) => each.isNotEmpty)) {
      doNext(List.generate(pending.length, (i) => pending[i].removeFirst(),
          growable: false));
    }
  }

  @override
  void notifyError(Disposable subscription, int index, Object error,
      [StackTrace stackTrace]) {
    doError(error, stackTrace);
  }

  @override
  void notifyComplete(Disposable subscription, int index) {
    if (pending[index].isEmpty) {
      doComplete();
    }
  }
}
