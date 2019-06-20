library rx.operators.exhaust;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';

typedef ExhaustProjectFunction<T, R> = Observable<R> Function(T value);

/// Converts a higher-order [Observable] into a first-order Observable by
/// dropping inner [Observable]s while the previous inner Observable has not
/// yet completed.
Operator<Observable<T>, T> exhaust<T>({int concurrent = 1}) =>
    (subscriber, source) => source.subscribe(
        _ExhaustSubscriber(subscriber, (observable) => observable, concurrent));

/// Converts a higher-order [Observable] into a first-order Observable by
/// dropping inner [Observable]s while the previous inner Observable has not
/// yet completed.
Operator<T, R> exhaustMap<T, R>(ExhaustProjectFunction<T, R> project,
        {int concurrent = 1}) =>
    (subscriber, source) =>
        source.subscribe(_ExhaustSubscriber(subscriber, project, concurrent));

/// Converts a higher-order [Observable] into the same first-order Observable
/// by dropping inner [Observable]s while the previous inner Observable has not
/// yet completed.
Operator<T, R> exhaustMapTo<T, R>(Observable<R> observable,
        {int concurrent = 1}) =>
    (subscriber, source) => source.subscribe(
        _ExhaustSubscriber(subscriber, (_) => observable, concurrent));

class _ExhaustSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  final ExhaustProjectFunction<T, R> project;
  final int concurrent;

  bool hasCompleted = false;
  int active = 0;

  _ExhaustSubscriber(Observer<R> destination, this.project, this.concurrent)
      : super(destination) {
    if (concurrent < 1) {
      throw RangeError.range(concurrent, 1, null, 'concurrent');
    }
  }

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
