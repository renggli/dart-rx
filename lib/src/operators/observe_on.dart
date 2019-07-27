library rx.operators.observe_on;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Re-emits all notifications from the source with a custom scheduler.
Operator<T, T> observeOn<T>(Scheduler scheduler, {Duration delay}) =>
    (subscriber, source) =>
        source.subscribe(_ObserveOnSubscriber(subscriber, scheduler, delay));

class _ObserveOnSubscriber<T> extends Subscriber<T> {
  final Scheduler scheduler;
  final Duration delay;

  _ObserveOnSubscriber(Observer<T> destination, this.scheduler, this.delay)
      : super(destination);

  void _schedule(Callback0 callback) => delay == null
      ? scheduler.schedule(callback)
      : scheduler.scheduleRelative(delay, callback);

  @override
  void onNext(T value) => _schedule(() => doNext(value));

  @override
  void onError(Object error, [StackTrace stackTrace]) =>
      _schedule(() => doError(error, stackTrace));

  @override
  void onComplete() => _schedule(doComplete);
}
