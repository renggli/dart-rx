library rx.operators.switch_map;

import 'package:rx/core.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/observers/inner.dart';
import 'package:rx/src/subscriptions/sequential.dart';

typedef SwitchMapProject<T, R> = Observable<R> Function(T value);

/// Projects each source value to an [Observable] which is merged in the output
/// [Observable], emitting values only from the most recently projected
/// [Observable].
Operator<T, R> switchMap<T, R>(SwitchMapProject<T, R> project) =>
    (subscriber, source) =>
        source.subscribe(_SwitchMapSubscriber(subscriber, project));

/// Projects each source value to the same [Observable] which is flattened
/// multiple times with `switchMap` in the output [Observable].
Operator<T, R> switchMapTo<T, R>(Observable<R> observable) =>
    (subscriber, source) =>
        source.subscribe(_SwitchMapSubscriber(subscriber, (_) => observable));

class _SwitchMapSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  final SwitchMapProject<T, R> project;
  final SequentialSubscription subscription = SequentialSubscription();

  bool hasCompleted = false;

  _SwitchMapSubscriber(Observer<R> destination, this.project)
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
