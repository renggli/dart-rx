library rx.operators.single;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Returns the single element of an observable sequence, or emits [TooFewError]
/// if there was no element, or emits [TooManyError] if there was more than 1
/// element.
OperatorFunction<T, T> single<T>() => singleOrElse(
      tooFew: throwFunction0(TooFewError()),
      tooMany: throwFunction0(TooManyError()),
    );

/// Returns the single element of an observable sequence, or emits `tooFew`
/// if there was no element, or emits `tooMany` if there was more than 1
/// element.
OperatorFunction<T, T> singleOrDefault<T>({T tooFew, T tooMany}) =>
    singleOrElse(
      tooFew: constantFunction0(tooFew),
      tooMany: constantFunction0(tooMany),
    );

/// Returns the single element of an observable sequence, or evaluates the
/// `tooFew` callback if there was no element, or evaluates the `tooMany`
/// callback if there was more than 1 element.
OperatorFunction<T, T> singleOrElse<T>({Map0<T> tooFew, Map0<T> tooMany}) =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_SingleSubscriber<T>(subscriber, tooFew, tooMany)));

class _SingleSubscriber<T> extends Subscriber<T> {
  final Map0<T> tooFewCallback;
  final Map0<T> tooManyCallback;

  T singleValue;
  bool seenValue = false;

  _SingleSubscriber(
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
