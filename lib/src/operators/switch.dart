library rx.operators.switch_;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';
import 'package:rx/src/shared/functions.dart';
import 'package:rx/src/subscriptions/sequential.dart';

/// Emits values only from the most recently received higher-order [Observable].
Map1<Observable<Observable<R>>, Observable<R>> switchAll<R>() =>
    switchMap<Observable<R>, R>(identityFunction);

/// Emits values from the most recent higher-order [Observable] retrieved by
/// projecting the values of the source to higher-order [Observable]s.
Map1<Observable<T>, Observable<R>> switchMap<T, R>(
        Map1<T, Observable<R>> project) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_SwitchSubscriber<T, R>(subscriber, project)));

/// Emits all values from the most recent higher-order `observable`.
Map1<Observable, Observable<R>> switchMapTo<R>(Observable<R> observable) =>
    switchMap<Object, R>(constantFunction1(observable));

class _SwitchSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  final Map1<T, Observable<R>> project;
  final SequentialSubscription subscription = SequentialSubscription();

  bool hasCompleted = false;

  _SwitchSubscriber(Observer<R> destination, this.project)
      : super(destination) {
    add(subscription);
  }

  @override
  void onNext(T value) {
    final projectEvent = Event.map1(project, value);
    if (projectEvent is ErrorEvent) {
      doError(projectEvent.error, projectEvent.stackTrace);
    } else {
      subscription.current = InnerObserver(projectEvent.value, this);
    }
  }

  @override
  void onComplete() {
    hasCompleted = true;
    if (subscription.current.isClosed) {
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
    this.subscription.current = Subscription.empty();
    if (hasCompleted) {
      doComplete();
    }
  }
}
