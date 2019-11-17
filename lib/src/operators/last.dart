library rx.operators.last;

import '../core/errors.dart';
import '../core/events.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

extension LastOperator<T> on Observable<T> {
  /// Return the last item of an observable sequence, or emits an
  /// [TooFewError] otherwise.
  Observable<T> last() => lastOrElse(throwFunction0(TooFewError()));

  /// Return the last item of an observable sequence, or the provided
  /// default [value] otherwise.
  Observable<T> lastOrDefault([T value]) =>
      lastOrElse(constantFunction0(value));

  /// Return the last item of an observable sequence, or evaluate the
  /// provided [callback] otherwise.
  Observable<T> lastOrElse(Map0<T> callback) =>
      findLastOrElse(constantFunction1(true), callback);

  /// Return the last item an observable sequence matching the [predicate], or
  /// emits an [TooFewError] otherwise.
  Observable<T> findLast(Predicate1<T> predicate) =>
      findLastOrElse(predicate, throwFunction0(TooFewError()));

  /// Return the last item an observable sequence matching the [predicate], or
  /// the provided default [value] otherwise.
  Observable<T> findLastOrDefault(Predicate1<T> predicate, [T value]) =>
      findLastOrElse(predicate, constantFunction0(value));

  /// Return the last item an observable sequence matching the [predicate], or
  /// evaluate the provided [callback] otherwise.
  Observable<T> findLastOrElse(Predicate1<T> predicate, Map0<T> callback) =>
      LastObservable<T>(this, predicate, callback);
}

class LastObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Predicate1<T> predicate;
  final Map0<T> callback;

  LastObservable(this.delegate, this.predicate, this.callback);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = LastSubscriber<T>(observer, predicate, callback);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class LastSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;
  final Map0<T> callback;

  T lastValue;
  bool seenValue = false;

  LastSubscriber(Observer<T> observer, this.predicate, this.callback)
      : super(observer);

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent is ErrorEvent) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      lastValue = value;
      seenValue = true;
    }
  }

  @override
  void onComplete() {
    if (seenValue) {
      doNext(lastValue);
      doComplete();
    } else {
      final resultEvent = Event.map0(callback);
      if (resultEvent is ErrorEvent) {
        doError(resultEvent.error, resultEvent.stackTrace);
      } else {
        doNext(resultEvent.value);
        doComplete();
      }
    }
  }
}
