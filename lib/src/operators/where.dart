library rx.operators.where;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension WhereOperator<T> on Observable<T> {
  /// Filter items emitted by the source Observable by only emitting those that
  /// satisfy a specified predicate.
  Observable<T> where(Predicate1<T> predicate) =>
      WhereObservable<T>(this, predicate);
}

class WhereObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Predicate1<T> predicate;

  WhereObservable(this.delegate, this.predicate);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(WhereSubscriber<T>(observer, predicate));
}

class WhereSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;

  WhereSubscriber(Observer<T> observer, this.predicate) : super(observer);

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent is ErrorEvent) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      doNext(value);
    }
  }
}
