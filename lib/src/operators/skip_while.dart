library rx.operators.skip_while;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';
import '../shared/functions.dart';

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
  Disposable subscribe(Observer<T> observer) {
    final subscriber = SkipWhileSubscriber<T>(observer, predicate);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SkipWhileSubscriber<T> extends Subscriber<T> {
  final Predicate1<T> predicate;
  bool skipping = true;

  SkipWhileSubscriber(Observer<T> observer, this.predicate) : super(observer);

  @override
  void onNext(T value) {
    if (skipping) {
      final predicateEvent = Event.map1(predicate, value);
      if (predicateEvent.isError) {
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
