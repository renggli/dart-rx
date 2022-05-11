import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension WhereOperator<T> on Observable<T> {
  /// Filter items emitted by the source Observable by only emitting those that
  /// satisfy a specified predicate.
  Observable<T> where(Predicate1<T> predicate) =>
      WhereObservable<T>(this, predicate);
}

class WhereObservable<T> implements Observable<T> {
  WhereObservable(this.delegate, this.predicate);

  final Observable<T> delegate;
  final Predicate1<T> predicate;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = WhereSubscriber<T>(observer, predicate);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class WhereSubscriber<T> extends Subscriber<T> {
  WhereSubscriber(Observer<T> super.observer, this.predicate);

  final Predicate1<T> predicate;

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent.isError) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      doNext(value);
    }
  }
}
