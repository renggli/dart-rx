library rx.operators.materialize;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Materialize events into a stream of [Event] objects: [NextEvent],
/// [ErrorEvent] and [CompleteEvent].
Map1<Observable<T>, Observable<Event<T>>> materialize<T>() =>
    (source) => source.lift((source, subscriber) =>
        source.subscribe(_MaterializeSubscriber<T>(subscriber)));

class _MaterializeSubscriber<T> extends Subscriber<T> {
  _MaterializeSubscriber(Observer<Event<T>> destination) : super(destination);

  @override
  void onNext(T value) => doNext(NextEvent<T>(value));

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    doNext(ErrorEvent<T>(error, stackTrace));
    doComplete();
  }

  @override
  void onComplete() {
    doNext(CompleteEvent<T>());
    doComplete();
  }
}
