library rx.operators.dematerialize;

import 'package:rx/src/core/errors.dart';
import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Dematerialize events into a stream from [Event] objects of type [NextEvent],
/// [ErrorEvent] and [CompleteEvent].
Map1<Observable<Event<T>>, Observable<T>> dematerialize<T>() =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_DematerializeSubscriber<T>(subscriber)));

class _DematerializeSubscriber<T> extends Subscriber<Event<T>> {
  _DematerializeSubscriber(Observer<T> destination) : super(destination);

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
