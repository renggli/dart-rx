library rx.operators.merge_map;

import 'dart:collection';

import 'package:rx/src/core/constants.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';

typedef MapProjectFunction<T, R> = Observable<R> Function(T value);

/// Applies a given project function to each value emitted by the source
/// Observable, and emits the resulting values as an Observable.
Operator<T, R> mergeMap<T, R>(MapProjectFunction<T, R> project,
        {int concurrent = maxInteger}) =>
    (subscriber, source) =>
        source.subscribe(_MergeSubscriber(subscriber, project, concurrent));

/// Projects each source value to the same [Observable] which is merged multiple
/// times in the output [Observable].
Operator<T, R> mergeMapTo<T, R>(Observable<R> observable,
        {int concurrent = maxInteger}) =>
    (subscriber, source) => source
        .subscribe(_MergeSubscriber(subscriber, (_) => observable, concurrent));

class _MergeSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, int> {
  final MapProjectFunction<T, R> project;
  final num concurrent;

  Queue<T> buffer = Queue();
  bool hasCompleted = false;
  int active = 0;

  _MergeSubscriber(Observer<R> destination, this.project, this.concurrent)
      : super(destination);

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
    //unsubscribe();
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
