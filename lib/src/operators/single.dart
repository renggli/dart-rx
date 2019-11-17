library rx.operators.single;

import '../core/errors.dart';
import '../core/events.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

extension SingleOperator<T> on Observable<T> {
  /// Returns the single element of an observable sequence, or emits
  /// [TooFewError] if there was no element, or emits [TooManyError] if there
  /// was more than 1 element.
  Observable<T> single() => singleOrElse(
        tooFew: throwFunction0(TooFewError()),
        tooMany: throwFunction0(TooManyError()),
      );

  /// Returns the single element of an observable sequence, or emits `tooFew`
  /// if there was no element, or emits `tooMany` if there was more than 1
  /// element.
  Observable<T> singleOrDefault({T tooFew, T tooMany}) => singleOrElse(
        tooFew: constantFunction0(tooFew),
        tooMany: constantFunction0(tooMany),
      );

  /// Returns the single element of an observable sequence, or evaluates the
  /// `tooFew` callback if there was no element, or evaluates the `tooMany`
  /// callback if there was more than 1 element.
  Observable<T> singleOrElse({Map0<T> tooFew, Map0<T> tooMany}) =>
      SingleObservable<T>(this, tooFew, tooMany);
}

class SingleObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Map0<T> tooFewCallback;
  final Map0<T> tooManyCallback;

  SingleObservable(this.delegate, this.tooFewCallback, this.tooManyCallback);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber =
        SingleSubscriber<T>(observer, tooFewCallback, tooManyCallback);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SingleSubscriber<T> extends Subscriber<T> {
  final Map0<T> tooFewCallback;
  final Map0<T> tooManyCallback;

  T singleValue;
  bool seenValue = false;

  SingleSubscriber(
      Observer<T> destination, this.tooFewCallback, this.tooManyCallback)
      : super(destination);

  @override
  void onNext(T value) {
    if (seenValue) {
      doCallback(tooManyCallback);
    } else {
      singleValue = value;
      seenValue = true;
    }
  }

  @override
  void onComplete() {
    if (seenValue) {
      doNext(singleValue);
      doComplete();
    } else {
      doCallback(tooFewCallback);
    }
  }

  void doCallback(Map0<T> callback) {
    final callbackEvent = Event.map0(callback);
    if (callbackEvent is ErrorEvent) {
      doError(callbackEvent.error, callbackEvent.stackTrace);
    } else {
      doNext(callbackEvent.value);
      doComplete();
    }
  }
}
