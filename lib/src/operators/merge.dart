library rx.operators.merge;

import 'dart:collection';

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';
import 'package:rx/src/shared/constants.dart';
import 'package:rx/src/shared/functions.dart';

extension MergeAllOperator<T> on Observable<Observable<T>> {
  /// Emits all merged values from a higher-order [Observable]. Subscribes to
  /// at most `concurrent` sources.
  Observable<T> mergeAll({int concurrent = maxInteger}) =>
      mergeMap<T>(identityFunction, concurrent: concurrent);
}

extension MergeMapOperator<T> on Observable<T> {
  /// Emits all merged values from a single higher-order `observable. Subscribes
  /// to at most `concurrent` sources.
  Observable<R> mergeMapTo<R>(Observable<R> observable,
      {int concurrent = maxInteger}) =>
    mergeMap<R>(constantFunction1(observable), concurrent: concurrent);

  /// Emits all merged values from a higher-order [Observable] retrieved by
  /// projecting the values of the source to higher-order [Observable]s.
  /// Subscribes to at most `concurrent` sources.
  Observable<R> mergeMap<R>(Map1<T, Observable<R>> project,
      {int concurrent = maxInteger}) {
    RangeError.checkValidRange(1, null, concurrent, 'concurrent');
    return MergeObservable<T, R>(this, project, concurrent);
  }
}

class MergeObservable<T, R> extends Observable<R> {
  final Observable<T> delegate;
  final Map1<T, Observable<R>> project;
  final num concurrent;

  MergeObservable(this.delegate, this.project, this.concurrent);

  @override
  Subscription subscribe(Observer<R> observer) =>
      delegate.subscribe(MergeSubscriber<T, R>(observer, project, concurrent));
}

class MergeSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, int> {
  final Map1<T, Observable<R>> project;
  final num concurrent;

  Queue<T> buffer = Queue();
  bool hasCompleted = false;
  int active = 0;

  MergeSubscriber(Observer<R> observer, this.project, this.concurrent)
      : super(observer);

  @override
  void onNext(T value) {
    if (active < concurrent) {
      final projectEvent = Event.map1(project, value);
      if (projectEvent is ErrorEvent) {
        doError(projectEvent.error, projectEvent.stackTrace);
      } else {
        add(InnerObserver(projectEvent.value, this, active++));
      }
    } else {
      buffer.addLast(value);
    }
  }

  @override
  void onComplete() {
    hasCompleted = true;
    if (active == 0 && buffer.isEmpty) {
      doComplete();
    }
  }

  @override
  void notifyNext(Subscription subscription, int state, R value) =>
      doNext(value);

  @override
  void notifyError(Subscription subscription, int state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Subscription subscription, int state) {
    remove(subscription);
    active--;
    if (buffer.isNotEmpty) {
      onNext(buffer.removeFirst());
    } else if (active == 0 && hasCompleted) {
      doComplete();
    }
  }
}
