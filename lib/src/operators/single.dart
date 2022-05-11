import 'package:more/functional.dart';

import '../core/errors.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension SingleOperator<T> on Observable<T> {
  /// Emits the single element of this [Observable], or emits [TooFewError] if
  /// there was no element, or emits [TooManyError] if there was more than 1
  /// element.
  Observable<T> single() => singleOrElse(
        tooFew: throwFunction0(TooFewError()),
        tooMany: throwFunction0(TooManyError()),
      );

  /// Emits the single element of this [Observable], or emits `tooFew` if there
  /// was no element, or emits `tooMany` if there was more than 1 element.
  Observable<T> singleOrDefault({required T tooFew, required T tooMany}) =>
      singleOrElse(
        tooFew: constantFunction0(tooFew),
        tooMany: constantFunction0(tooMany),
      );

  /// Emits the single element of this [Observable], or evaluates the `tooFew`
  /// callback if there was no element, or evaluates the `tooMany` callback if
  /// there was more than 1 element.
  Observable<T> singleOrElse(
          {required Map0<T> tooFew, required Map0<T> tooMany}) =>
      SingleObservable<T>(this, tooFew, tooMany);
}

class SingleObservable<T> implements Observable<T> {
  SingleObservable(this.delegate, this.tooFewCallback, this.tooManyCallback);

  final Observable<T> delegate;
  final Map0<T> tooFewCallback;
  final Map0<T> tooManyCallback;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber =
        SingleSubscriber<T>(observer, tooFewCallback, tooManyCallback);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SingleSubscriber<T> extends Subscriber<T> {
  SingleSubscriber(
      Observer<T> super.destination, this.tooFewCallback, this.tooManyCallback);

  final Map0<T> tooFewCallback;
  final Map0<T> tooManyCallback;

  T? singleValue;
  bool seenValue = false;

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
    if (callbackEvent.isError) {
      doError(callbackEvent.error, callbackEvent.stackTrace);
    } else {
      doNext(callbackEvent.value);
      doComplete();
    }
  }
}
