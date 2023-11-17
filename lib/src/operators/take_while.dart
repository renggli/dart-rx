import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension TakeWhileOperator<T> on Observable<T> {
  /// Emits values while the [predicate] returns `true`.
  Observable<T> takeWhile(Predicate1<T> predicate, {bool inclusive = false}) =>
      TakeWhileObservable<T>(this, predicate, inclusive);
}

class TakeWhileObservable<T> implements Observable<T> {
  TakeWhileObservable(this.delegate, this.predicate, this.inclusive);

  final Observable<T> delegate;
  final Predicate1<T> predicate;
  final bool inclusive;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = TakeWhileSubscriber<T>(observer, predicate, inclusive);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TakeWhileSubscriber<T> extends Subscriber<T> {
  TakeWhileSubscriber(
      Observer<T> super.observer, this.predicate, this.inclusive);

  final Predicate1<T> predicate;
  final bool inclusive;

  @override
  void onNext(T value) {
    final predicateEvent = Event.map1(predicate, value);
    if (predicateEvent.isError) {
      doError(predicateEvent.error, predicateEvent.stackTrace);
    } else if (predicateEvent.value) {
      doNext(value);
    } else {
      if (inclusive) {
        doNext(value);
      }
      doComplete();
    }
  }
}
