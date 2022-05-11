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

class ZipObservable<T> implements Observable<List<T>> {
  ZipObservable(this.delegate);

  final Observable<Observable<T>> delegate;

  @override
  Disposable subscribe(Observer<List<T>> observer) {
    final subscriber = ZipSubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ZipSubscriber<T> extends Subscriber<Observable<T>>
    implements InnerEvents<T, int> {
  ZipSubscriber(Observer<List<T>> super.observer);

  final List<Observable<T>> observables = [];
  final List<ListQueue<T>> pending = [];

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
        add(InnerObserver(this, observables[i], i));
      }
    }
  }

  @override
  void notifyNext(Disposable disposable, int index, T value) {
    pending[index].addLast(value);
    if (pending.every((each) => each.isNotEmpty)) {
      doNext(List.generate(pending.length, (i) => pending[i].removeFirst(),
          growable: false));
    }
  }

  @override
  void notifyError(
      Disposable disposable, int index, Object error, StackTrace stackTrace) {
    doError(error, stackTrace);
  }

  @override
  void notifyComplete(Disposable disposable, int index) {
    if (pending[index].isEmpty) {
      doComplete();
    }
  }
}
