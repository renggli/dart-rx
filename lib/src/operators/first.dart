library rx.operators.first;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension FirstOperator<T> on Observable<T> {
  /// Return the first item of an observable sequence, or emits an
  /// [TooFewError] otherwise.
  Observable<T> first() =>
      firstOrElse(throwFunction0(TooFewError()));

  /// Return the first item of an observable sequence, or the provided
  /// default [value] otherwise.
  Observable<T> firstOrDefault([T value]) =>
      firstOrElse(constantFunction0(value));

  /// Return the first item of an observable sequence, or evaluate the
  /// provided [callback] otherwise.
  Observable<T> firstOrElse(Map0<T> callback) =>
      findFirstOrElse(constantFunction1(true), callback);

  /// Return the first item an observable sequence matching the [predicate], or
  /// emits an [TooFewError] otherwise.
  Observable<T> findFirst(Predicate1<T> predicate) =>
      findFirstOrElse(predicate, throwFunction0(TooFewError()));

  /// Return the first item an observable sequence matching the [predicate], or
  /// the provided default [value] otherwise.
  Observable<T> findFirstOrDefault(Predicate1<T> predicate, [T value]) =>
      findFirstOrElse(predicate, constantFunction0(value));

  /// Return the first item an observable sequence matching the [predicate], or
  /// evaluate the provided [callback] otherwise.
  Observable<T> findFirstOrElse(Predicate1<T> predicate, Map0<T> callback) =>
      FirstObservable<T>(this, predicate, callback);
}

class FirstObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Predicate1<T> predicate;
  final Map0<T> callback;

  FirstObservable(this.delegate, this.predicate, this.callback);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(FirstSubscriber<T>(observer, predicate, callback));
}

class FirstSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;
  final Map0<T> callback;

  FirstSubscriber(Observer<T> observer, this.predicate, this.callback)
      : super(observer);

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent is ErrorEvent) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      doNext(value);
      doComplete();
    }
  }

  @override
  void onComplete() {
    final resultEvent = Event.map0(callback);
    if (resultEvent is ErrorEvent) {
      doError(resultEvent.error, resultEvent.stackTrace);
    } else {
      doNext(resultEvent.value);
      doComplete();
    }
  }
}
