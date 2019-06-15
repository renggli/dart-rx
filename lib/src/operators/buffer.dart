library rx.operators.buffer;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/scheduler.dart';
import 'package:rx/src/core/subscriber.dart';
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

class _BufferSubscriber<T> extends Subscriber<T> {
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
      add(trigger.subscribe(Observer(
        next: (value) => flush(),
        error: (error, [stackTrace]) => doError(error, stackTrace),
      )));
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
