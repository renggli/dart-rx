library rx.operators.skip_while;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension SkipWhileOperator<T> on Observable<T> {
  /// Skips over the values while the [predicate] is `true`.
  Observable<T> skipWhile(Predicate1<T> predicate) =>
      SkipWhileObservable<T>(this, predicate);
}

class SkipWhileObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Predicate1<T> predicate;

  SkipWhileObservable(this.delegate, this.predicate);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(SkipWhileSubscriber<T>(observer, predicate));
}

class SkipWhileSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;
  bool skipping = true;

  SkipWhileSubscriber(Observer<T> observer, this.predicate) : super(observer);

  @override
  void onNext(T value) {
    if (skipping) {
      final predicateEvent = Event.map1(predicate, value);
      if (predicateEvent is ErrorEvent) {
        doError(predicateEvent.error, predicateEvent.stackTrace);
      } else if (!predicateEvent.value) {
        skipping = false;
        doNext(value);
      }
    } else {
      doNext(value);
    }
  }
}
