import 'dart:collection';

import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';
import '../observers/inner.dart';
import '../shared/constants.dart';

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
          {int concurrent = maxInteger}) =>
      MergeObservable<T, R>(this, project, concurrent);
}

class MergeObservable<T, R> implements Observable<R> {
  MergeObservable(this.delegate, this.project, this.concurrent) {
    RangeError.checkValidRange(1, null, concurrent, 'concurrent');
  }

  final Observable<T> delegate;
  final Map1<T, Observable<R>> project;
  final int concurrent;

  @override
  Disposable subscribe(Observer<R> observer) {
    final subscriber = MergeSubscriber<T, R>(observer, project, concurrent);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class MergeSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  MergeSubscriber(Observer<R> super.observer, this.project, this.concurrent);

  final Map1<T, Observable<R>> project;
  final int concurrent;

  Queue<T> buffer = Queue();
  bool hasCompleted = false;
  int active = 0;

  @override
  void onNext(T value) {
    if (active < concurrent) {
      final projectEvent = Event.map1(project, value);
      if (projectEvent.isError) {
        doError(projectEvent.error, projectEvent.stackTrace);
      } else {
        active++;
        add(InnerObserver(this, projectEvent.value, null));
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
  void notifyNext(Disposable disposable, void state, R value) => doNext(value);

  @override
  void notifyError(Disposable disposable, void state, Object error,
          StackTrace stackTrace) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) {
    remove(disposable);
    active--;
    if (buffer.isNotEmpty) {
      onNext(buffer.removeFirst());
    } else if (active == 0 && hasCompleted) {
      doComplete();
    }
  }
}
