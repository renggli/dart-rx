library rx.operators.dematerialize;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

extension DematerializeOperator<T> on Observable<Event<T>> {
  /// Dematerialize events into a stream from [Event] objects of type
  /// [NextEvent], [ErrorEvent] and [CompleteEvent].
  Observable<T> dematerialize() => DematerializeObservable<T>(this);
}

class DematerializeObservable<T> extends Observable<T> {
  final Observable<Event<T>> delegate;

  DematerializeObservable(this.delegate);

  @override
  Subscription subscribe(Observer<T> observer) =>
      delegate.subscribe(DematerializeSubscriber<T>(observer));
}

class DematerializeSubscriber<T> extends Subscriber<Event<T>> {
  DematerializeSubscriber(Observer<T> observer) : super(observer);

  @override
  void onNext(Event<T> value) {
    if (value is NextEvent<T>) {
      doNext(value.value);
    } else if (value is ErrorEvent<T>) {
      doError(value.error, value.stackTrace);
    } else if (value is CompleteEvent<T>) {
      doComplete();
    } else {
      doError(UnexpectedEventError(value), StackTrace.current);
    }
  }
}
