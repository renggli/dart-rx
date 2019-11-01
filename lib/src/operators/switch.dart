library rx.operators.switch_;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';
import 'package:rx/src/shared/functions.dart';
import 'package:rx/src/subscriptions/sequential.dart';

extension SwitchAllOperator<T> on Observable<Observable<T>> {
  /// Emits values only from the most recently received higher-order
  /// [Observable].
  Observable<T> switchAll() => switchMap<T>(identityFunction);
}

extension SwitchMapOperator<T> on Observable<T> {
  /// Emits all values from the most recent higher-order `observable`.
  Observable<R> switchMapTo<R>(Observable<R> observable) =>
      switchMap<R>(constantFunction1(observable));

  /// Emits values from the most recent higher-order [Observable] retrieved by
  /// projecting the values of the source to higher-order [Observable]s.
  Observable<R> switchMap<R>(Map1<T, Observable<R>> project) =>
      SwitchObservable<T, R>(this, project);
}

class SwitchObservable<T, R> extends Observable<R> {
  final Observable<T> delegate;
  final Map1<T, Observable<R>> project;

  SwitchObservable(this.delegate, this.project);

  @override
  Subscription subscribe(Observer<R> observer) {
    final subscriber = SwitchSubscriber<T, R>(observer, project);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SwitchSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  final Map1<T, Observable<R>> project;
  final SequentialSubscription subscription = SequentialSubscription();

  bool hasCompleted = false;

  SwitchSubscriber(Observer<R> observer, this.project) : super(observer) {
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
