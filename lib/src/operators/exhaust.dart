library rx.operators.exhaust;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';
import 'package:rx/src/shared/functions.dart';

extension ExhaustAllOperator<T> on Observable<Observable<T>> {
  /// Emits and completes higher-order [Observable]. Subscribes to at most
  /// `concurrent` sources, drops observables exceeding this threshold.
  Observable<T> exhaustAll({int concurrent = 1}) =>
      exhaustMap<T>(identityFunction, concurrent: concurrent);
}

extension ExhaustMapOperator<T> on Observable<T> {
  /// Emits and completes values from a single higher-order [Observable].
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
  Subscription subscribe(Observer<R> observer) =>
      delegate.subscribe(ExhaustSubscriber<T, R>(
          observer, project, concurrent));
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
        add(InnerObserver(projectEvent.value, this));
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
  void notifyNext(Subscription subscription, void state, R value) =>
      doNext(value);

  @override
  void notifyError(Subscription subscription, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Subscription subscription, void state) {
    active--;
    remove(subscription);
    if (active == 0 && hasCompleted) {
      doComplete();
    }
  }
}
