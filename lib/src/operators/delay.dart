import 'package:more/functional.dart';

import '../constructors/timer.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/composite.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';
import '../observers/inner.dart';
import '../schedulers/scheduler.dart';

typedef DurationSelector<T, R> = Observable<R> Function(T value);

extension DelayOperator<T> on Observable<T> {
  /// Delays the emission of items from this [Observable] until the Observable
  /// returned from [durationSelector] triggers.
  Observable<T> delay<R>(DurationSelector<T, R> durationSelector) =>
      DelayObservable<T, R>(this, durationSelector);

  /// Delays the emission of items from this [Observable] by a given timeout.
  Observable<T> delayTime(Duration duration, {Scheduler? scheduler}) =>
      delay<int>(
          constantFunction1(timer(delay: duration, scheduler: scheduler)));
}

class DelayObservable<T, R> implements Observable<T> {
  DelayObservable(this.delegate, this.durationSelector);

  final Observable<T> delegate;
  final DurationSelector<T, R> durationSelector;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = DelaySubscriber<T, R>(observer, durationSelector);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class DelaySubscriber<T, R> extends Subscriber<T> implements InnerEvents<R, T> {
  DelaySubscriber(Observer<T> super.observer, this.durationSelector) {
    add(pendingDisposables);
  }

  final DurationSelector<T, R> durationSelector;
  final CompositeDisposable pendingDisposables = CompositeDisposable();

  bool hasCompleted = false;

  @override
  void onNext(T value) {
    final durationEvent = Event.map1(durationSelector, value);
    if (durationEvent.isError) {
      doError(durationEvent.error, durationEvent.stackTrace);
    } else {
      pendingDisposables.add(InnerObserver(this, durationEvent.value, value));
    }
  }

  @override
  void onComplete() {
    hasCompleted = true;
    tryComplete();
  }

  @override
  void notifyNext(Disposable disposable, T state, R object) {
    emitValue(disposable, state);
  }

  @override
  void notifyError(
      Disposable disposable, T state, Object error, StackTrace stackTrace) {
    doError(error, stackTrace);
  }

  @override
  void notifyComplete(Disposable disposable, T state) {
    emitValue(disposable, state);
  }

  void emitValue(Disposable disposable, T value) {
    if (pendingDisposables.contains(disposable)) {
      doNext(value);
      pendingDisposables.remove(disposable);
    }
    tryComplete();
  }

  void tryComplete() {
    if (hasCompleted && pendingDisposables.isEmpty) {
      doComplete();
    }
  }
}
