library rx.operators.merge_map;

import 'dart:collection';

import 'package:rx/src/core/constants.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

typedef ProjectFunction<T, R> = Observable<R> Function(T value);

/// Applies a given project function to each value emitted by the source
/// Observable, and emits the resulting values as an Observable.
Operator<T, R> mergeMap<T, R>(ProjectFunction<T, R> project,
        {int concurrent = maxInteger}) =>
    _MergeMapOperator(project, concurrent);

class _MergeMapOperator<T, R> implements Operator<T, R> {
  final ProjectFunction<T, R> project;
  final num concurrent;

  _MergeMapOperator(this.project, this.concurrent);

  @override
  Subscription call(Observable<T> source, Observer<R> destination) =>
      source.subscribe(_MergeMapSubscriber(destination, project, concurrent));
}

class _MergeMapSubscriber<T, R> extends Subscriber<T> {
  final ProjectFunction<T, R> project;
  final num concurrent;

  Queue<T> buffer = Queue();
  bool hasCompleted = false;
  int active = 0;

  _MergeMapSubscriber(Observer<R> destination, this.project, this.concurrent)
      : super(destination);

  @override
  void onNext(T value) {
    if (active < concurrent) {
      Observable<R> observable;
      try {
        observable = project(value);
      } catch (error, stackTrace) {
        doError(error, stackTrace);
        return;
      }
      active++;
      Subscription subscription;
      subscription = observable.subscribe(Observer(
        next: doNext,
        error: doError,
        complete: () => innerComplete(subscription),
      ));
      add(subscription);
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

  void innerComplete(Subscription subscription) {
    remove(subscription);
    active--;
    if (buffer.isNotEmpty) {
      onNext(buffer.removeFirst());
    } else if (active == 0 && hasCompleted) {
      doComplete();
    }
  }
}
