library rx.operators.exhaust;

import '../core/events.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';
import '../shared/functions.dart';

extension ExhaustAllOperator<T> on Observable<Observable<T>> {
  /// Emits and completes higher-order [Observable]. Subscribes to at most
  /// `concurrent` sources, and drops observables exceeding this threshold.
  Observable<T> exhaustAll({int concurrent = 1}) =>
      exhaustMap<T>(identityFunction, concurrent: concurrent);
}

extension ExhaustMapOperator<T> on Observable<T> {
  /// Emits and completes values from single higher-order [Observable].
  /// Subscribes to at most `concurrent` sources, drops observables exceeding
  /// this threshold.
  Observable<R> exhaustMapTo<R>(Observable<R> observable,
          {int concurrent = 1}) =>
      exhaustMap<R>(constantFunction1(observable), concurrent: concurrent);

  /// Emits and completes values from a higher-order [Observable] retrieved by
  /// projecting the values of the source to higher-order [Observable]s.
  /// Subscribes to at most `concurrent` sources, drops observables exceeding
  /// this threshold.
  Observable<R> exhaustMap<R>(Map1<T, Observable<R>> project,
      {int concurrent = 1}) {
    RangeError.checkValidRange(1, null, concurrent, 'concurrent');
    return ExhaustObservable<T, R>(this, project, concurrent);
  }
}

class ExhaustObservable<T, R> extends Observable<R> {
  final Observable<T> delegate;
  final Map1<T, Observable<R>> project;
  final int concurrent;

  ExhaustObservable(this.delegate, this.project, this.concurrent);

  @override
  Disposable subscribe(Observer<R> observer) {
    final subscriber = ExhaustSubscriber<T, R>(observer, project, concurrent);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class ExhaustSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  final Map1<T, Observable<R>> project;
  final int concurrent;

  bool hasCompleted = false;
  int active = 0;

  ExhaustSubscriber(Observer<R> observer, this.project, this.concurrent)
      : super(observer);

  @override
  void onNext(T value) {
    if (active < concurrent) {
      final projectEvent = Event.map1(project, value);
      if (projectEvent is ErrorEvent) {
        doError(projectEvent.error, projectEvent.stackTrace);
      } else {
        active++;
        add(InnerObserver(this, projectEvent.value));
      }
    }
  }

  @override
  void onComplete() {
    hasCompleted = true;
    if (active == 0) {
      doComplete();
    }
  }

  @override
  void notifyNext(Disposable disposable, void state, R value) => doNext(value);

  @override
  void notifyError(Disposable disposable, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) {
    active--;
    remove(disposable);
    if (active == 0 && hasCompleted) {
      doComplete();
    }
  }
}
