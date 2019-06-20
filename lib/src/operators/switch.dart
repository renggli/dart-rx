library rx.operators.switch_;

import 'package:rx/core.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/observers/inner.dart';
import 'package:rx/src/subscriptions/sequential.dart';

/// Emits values only from the most recently received higher-order [Observable].
Operator<Observable<R>, R> switchAll<R>() => (subscriber, source) =>
    source.subscribe(_SwitchSubscriber(subscriber, identityFunction));

/// Emits values from the most recent higher-order [Observable] retrieved by
/// projecting the values of the source to higher-order [Observable]s.
Operator<T, R> switchMap<T, R>(Map1<T, Observable<R>> project) =>
    (subscriber, source) =>
        source.subscribe(_SwitchSubscriber(subscriber, project));

/// Emits all values from the most recent higher-order `observable`.
Operator<T, R> switchMapTo<T, R>(Observable<R> observable) =>
    (subscriber, source) => source.subscribe(
        _SwitchSubscriber(subscriber, constantFunction1(observable)));

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
