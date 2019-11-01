library rx.operators.materialize;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

extension MaterializeOperator<T> on Observable<T> {
  /// Materialize events into a stream of [Event] objects: [NextEvent],
  /// [ErrorEvent] and [CompleteEvent].
  Observable<Event<T>> materialize() => MaterializeObservable<T>(this);
}

class MaterializeObservable<T> extends Observable<Event<T>> {
  final Observable<T> delegate;

  MaterializeObservable(this.delegate);

  @override
  Subscription subscribe(Observer<Event<T>> observer) {
    final subscriber = MaterializeSubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class MaterializeSubscriber<T> extends Subscriber<T> {
  MaterializeSubscriber(Observer<Event<T>> destination) : super(destination);

  @override
  void onNext(T value) => doNext(Event<T>.next(value));

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    doNext(Event<T>.error(error, stackTrace));
    doComplete();
  }

  @override
  void onComplete() {
    doNext(Event<T>.complete());
    doComplete();
  }
}
