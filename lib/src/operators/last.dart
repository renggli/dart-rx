import 'package:more/functional.dart';

import '../core/errors.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension LastOperator<T> on Observable<T> {
  /// Emits the last item of this [Observable], or emits an [TooFewError]
  /// otherwise.
  Observable<T> last() => lastOrElse(throwFunction0(TooFewError()));

  /// Emits the last item of this [Observable], or the provided default [value]
  /// otherwise.
  Observable<T> lastOrDefault(T value) => lastOrElse(constantFunction0(value));

  /// Emits the last item of this [Observable], or evaluate the provided
  /// [callback] otherwise.
  Observable<T> lastOrElse(Map0<T> callback) =>
      findLastOrElse(constantFunction1(true), callback);

  /// Emits the last item of this [Observable] matching the [predicate], or
  /// emits an [TooFewError] otherwise.
  Observable<T> findLast(Predicate1<T> predicate) =>
      findLastOrElse(predicate, throwFunction0(TooFewError()));

  /// Emits the last item of this [Observable] matching the [predicate], or
  /// the provided default [value] otherwise.
  Observable<T> findLastOrDefault(Predicate1<T> predicate, T value) =>
      findLastOrElse(predicate, constantFunction0(value));

  /// Emits the last item of this [Observable] matching the [predicate], or
  /// evaluate the provided [callback] otherwise.
  Observable<T> findLastOrElse(Predicate1<T> predicate, Map0<T> callback) =>
      LastObservable<T>(this, predicate, callback);
}

class LastObservable<T> implements Observable<T> {
  LastObservable(this.delegate, this.predicate, this.callback);

  final Observable<T> delegate;
  final Predicate1<T> predicate;
  final Map0<T> callback;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = LastSubscriber<T>(observer, predicate, callback);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class LastSubscriber<T> extends Subscriber<T> {
  LastSubscriber(Observer<T> super.observer, this.predicate, this.callback);

  final Predicate1<T> predicate;
  final Map0<T> callback;

  T? lastValue;
  bool seenValue = false;

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent.isError) {
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
      if (resultEvent.isError) {
        doError(resultEvent.error, resultEvent.stackTrace);
      } else {
        doNext(resultEvent.value);
        doComplete();
      }
    }
  }
}
