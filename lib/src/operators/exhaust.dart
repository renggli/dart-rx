library rx.operators.exhaust;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';
import 'package:rx/src/shared/functions.dart';

/// Emits and completes higher-order [Observable]. Subscribes to at most
/// `concurrent` sources, drops observables exceeding this threshold.
OperatorFunction<Observable<R>, R> exhaustAll<R>({int concurrent = 1}) =>
    exhaustMap<Observable<R>, R>(identityFunction, concurrent: concurrent);

/// Emits and completes values from a higher-order [Observable] retrieved by
/// projecting the values of the source to higher-order [Observable]s.
/// Subscribes to at most `concurrent` sources, drops observables exceeding
/// this threshold.
OperatorFunction<T, R> exhaustMap<T, R>(Map1<T, Observable<R>> project,
    {int concurrent = 1}) {
  RangeError.checkValidRange(1, null, concurrent, 'concurrent');
  return (source) => source.lift((source, subscriber) => source
      .subscribe(_ExhaustSubscriber<T, R>(subscriber, project, concurrent)));
}

/// Emits and completes values from a single higher-order [Observable].
/// Subscribes to at most `concurrent` sources, drops observables exceeding
/// this threshold.
OperatorFunction<Object, R> exhaustMapTo<R>(Observable<R> observable,
        {int concurrent = 1}) =>
    exhaustMap<Object, R>(constantFunction1(observable),
        concurrent: concurrent);

class _ExhaustSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  final Map1<T, Observable<R>> project;
  final int concurrent;

  bool hasCompleted = false;
  int active = 0;

  _ExhaustSubscriber(Observer<R> destination, this.project, this.concurrent)
      : super(destination);

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
