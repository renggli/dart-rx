library rx.operators.single;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Callback throwing an error, or returning an alternate value.
typedef SingleCallback<T> = T Function();

/// Returns the single element of an observable sequence, or emits [TooFewError]
/// if there was no element, or emits [TooManyError] if there was more than 1
/// element.
Operator<T, T> single<T>() => singleOrElse(
      tooFew: () => throw TooFewError(),
      tooMany: () => throw TooManyError(),
    );

/// Returns the single element of an observable sequence, or emits `tooFew`
/// if there was no element, or emits `tooMany` if there was more than 1
/// element.
Operator<T, T> singleOrDefault<T>({T tooFew, T tooMany}) => singleOrElse(
      tooFew: () => tooFew,
      tooMany: () => tooMany,
    );

/// Returns the single element of an observable sequence, or evaluates the
/// `tooFew` callback if there was no element, or evaluates the `tooMany`
/// callback if there was more than 1 element.
Operator<T, T> singleOrElse<T>(
        {SingleCallback<T> tooFew, SingleCallback<T> tooMany}) =>
    (subscriber, source) =>
        source.subscribe(_SingleSubscriber(subscriber, tooFew, tooMany));

class _SingleSubscriber<T> extends Subscriber<T> {
  final SingleCallback<T> tooFewCallback;
  final SingleCallback<T> tooManyCallback;

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

  void doCallback(SingleCallback<T> callback) {
    final callbackEvent = Event.map0(callback);
    if (callbackEvent is ErrorEvent) {
      doError(callbackEvent.error, callbackEvent.stackTrace);
    } else {
      doNext(callbackEvent.value);
      doComplete();
    }
  }
}
