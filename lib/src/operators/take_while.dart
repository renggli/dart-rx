library rx.operators.take_while;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension TakeWhileOperator<T> on Observable<T> {
  /// Emits values while the [predicate] returns `true`.
  Observable<T> takeWhile(Predicate1<T> predicate) =>
      TakeWhileObservable<T>(this, predicate);
}

class TakeWhileObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Predicate1<T> predicate;

  TakeWhileObservable(this.delegate, this.predicate);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = TakeWhileSubscriber<T>(observer, predicate);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TakeWhileSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;

  TakeWhileSubscriber(Observer<T> observer, this.predicate) : super(observer);

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent is ErrorEvent) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      doNext(value);
    } else {
      doComplete();
    }
  }
}
