library rx.operators.merge;

import 'dart:collection';

import '../core/events.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';
import '../shared/constants.dart';
import '../shared/functions.dart';

extension MergeAllOperator<T> on Observable<Observable<T>> {
  /// For each observable of this [Observable], subscribe to at most
  /// `concurrent` observables and emit all values.
  Observable<T> mergeAll({int concurrent = maxInteger}) =>
      mergeMap<T>(identityFunction, concurrent: concurrent);
}

extension MergeMapOperator<T> on Observable<T> {
  /// For each value of this [Observable], merge all values from the single
  /// higher-order `observable`. Subscribe to at most `concurrent` sources.
  Observable<R> mergeMapTo<R>(Observable<R> observable,
          {int concurrent = maxInteger}) =>
      mergeMap<R>(constantFunction1(observable), concurrent: concurrent);

  /// For each value of this [Observable], transform that value to a
  /// higher-order observable with the provided `project` function and merge
  /// its emitted values. Subscribe to at most `concurrent` sources.
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
  Disposable subscribe(Observer<R> observer) {
    final subscriber = MergeSubscriber<T, R>(observer, project, concurrent);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
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
  void notifyNext(Disposable subscription, int state, R value) => doNext(value);

  @override
  void notifyError(Disposable subscription, int state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable subscription, int state) {
    remove(subscription);
    active--;
    if (buffer.isNotEmpty) {
      onNext(buffer.removeFirst());
    } else if (active == 0 && hasCompleted) {
      doComplete();
    }
  }
}
