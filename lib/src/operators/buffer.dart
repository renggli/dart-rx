library rx.operators.buffer;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/inner.dart';
import 'package:rx/src/schedulers/settings.dart';

/// Gathers items emitted by the source and bundles these items when the buffer
/// reached a [maxLength], when the buffer reached a [maxAge], or when another
/// observable [trigger]s.
Operator<T, List<T>> buffer<T>({
  Observable trigger,
  int maxLength,
  Duration maxAge,
  Scheduler scheduler,
}) =>
    (subscriber, source) => source.subscribe(_BufferSubscriber(
        subscriber, scheduler ?? defaultScheduler, trigger, maxLength, maxAge));

class _BufferSubscriber<T> extends Subscriber<T>
    implements InnerEvents<T, void> {
  final Scheduler scheduler;
  final int maxLength;
  final Duration maxAge;

  List<T> buffer;
  DateTime bufferBirth;

  _BufferSubscriber(Observer<List<T>> destination, this.scheduler,
      Observable trigger, this.maxLength, this.maxAge)
      : super(destination) {
    reset();
    if (trigger != null) {
      add(InnerObserver(trigger, this));
    }
  }

  @override
  void onNext(T value) {
    buffer.add(value);
    bufferBirth ??= scheduler.now;
    if (shouldFlush) {
      flush();
    }
  }

  @override
  void onComplete() {
    flush();
    doComplete();
  }

  @override
  void notifyNext(Subscription subscription, void state, T value) => flush();

  @override
  void notifyError(Subscription subscription, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Subscription subscription, void state) {}

  void reset() {
    buffer = [];
    bufferBirth = null;
  }

  bool get shouldFlush =>
      (maxLength != null && maxLength <= buffer.length) ||
      (maxAge != null &&
          bufferBirth != null &&
          bufferBirth.add(maxAge).isBefore(scheduler.now));

  void flush() {
    if (buffer.isNotEmpty) {
      doNext(buffer);
      reset();
    }
  }
}
