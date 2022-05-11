import 'package:more/functional.dart';

import '../core/errors.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension FirstOperator<T> on Observable<T> {
  /// Emits the first item of this [Observable], or emits an [TooFewError]
  /// otherwise.
  Observable<T> first() => firstOrElse(throwFunction0(TooFewError()));

  /// Emits the first item of this [Observable], or the provided default
  /// [value] otherwise.
  Observable<T> firstOrDefault(T value) =>
      firstOrElse(constantFunction0(value));

  /// Emits the first item of this [Observable], or evaluate the provided
  /// [callback] otherwise.
  Observable<T> firstOrElse(Map0<T> callback) =>
      findFirstOrElse(constantFunction1(true), callback);

  /// Emits the first item of this [Observable] sequence matching the
  /// [predicate], or emits an [TooFewError] otherwise.
  Observable<T> findFirst(Predicate1<T> predicate) =>
      findFirstOrElse(predicate, throwFunction0(TooFewError()));

  /// Emits the first item of this [Observable] sequence matching the
  /// [predicate], or the provided default [value] otherwise.
  Observable<T> findFirstOrDefault(Predicate1<T> predicate, T value) =>
      findFirstOrElse(predicate, constantFunction0(value));

  /// Emits the first item of this [Observable] sequence matching the
  /// [predicate], or evaluate the provided [callback] otherwise.
  Observable<T> findFirstOrElse(Predicate1<T> predicate, Map0<T> callback) =>
      FirstObservable<T>(this, predicate, callback);
}

class FirstObservable<T> implements Observable<T> {
  FirstObservable(this.delegate, this.predicate, this.callback);

  final Observable<T> delegate;
  final Predicate1<T> predicate;
  final Map0<T> callback;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = FirstSubscriber<T>(observer, predicate, callback);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class FirstSubscriber<T> extends Subscriber<T> {
  FirstSubscriber(Observer<T> super.observer, this.predicate, this.callback);

  final Predicate1<T> predicate;
  final Map0<T> callback;

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent.isError) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      doNext(value);
      doComplete();
    }
  }

  @override
  void onComplete() {
    final resultEvent = Event.map0(callback);
    if (resultEvent.isError) {
      doError(resultEvent.error, resultEvent.stackTrace);
    } else {
      doNext(resultEvent.value);
      doComplete();
    }
  }
}
