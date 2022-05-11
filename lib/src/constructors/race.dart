import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';
import 'empty.dart';

/// Creates an [Observable] that mirrors the first source to emit an item.
Observable<T> race<T>(Iterable<Observable<T>> sources) {
  final observables = sources.toList(growable: false);
  return observables.isEmpty
      ? empty()
      : observables.length == 1
          ? observables.first
          : RaceObservable<T>(observables);
}

class RaceObservable<T> implements Observable<T> {
  RaceObservable(this.observables);

  final List<Observable<T>> observables;

  @override
  Disposable subscribe(Observer<T> observer) =>
      RaceSubscriber<T>(observer, observables);
}

class RaceSubscriber<T> extends Subscriber<T> implements InnerEvents<T, void> {
  RaceSubscriber(Observer<T> super.observer, List<Observable<T>> observables) {
    for (final observable in observables) {
      final observer = InnerObserver<T, void>(this, observable, null);
      observers.add(observer);
      add(observer);
    }
  }

  final observers = <Disposable>[];

  @override
  void notifyNext(Disposable disposable, void state, T object) {
    // If we haven't selected the winner yet, unregister other observers.
    if (observers.isNotEmpty) {
      for (final observer in observers) {
        if (observer != disposable) {
          observer.dispose();
        }
      }
      observers.clear();
    }
    doNext(object);
  }

  @override
  void notifyError(Disposable disposable, void state, Object error,
          StackTrace stackTrace) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) => doComplete();
}
