library rx.operators.buffer;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/scheduler.dart';
import '../core/subscriber.dart';
import '../core/subscription.dart';
import '../observers/inner.dart';
import '../schedulers/settings.dart';

extension BufferOperator<T> on Observable<T> {
  /// Gathers items emitted by the source and bundles these items when the
  /// buffer reached a [maxLength], when the buffer reached a [maxAge], or when
  /// another observable [trigger]s.
  Observable<List<T>> buffer(
          {Scheduler scheduler,
          Observable trigger,
          int maxLength,
          Duration maxAge}) =>
      BufferObservable<T>(
          this, scheduler ?? defaultScheduler, trigger, maxLength, maxAge);
}

class BufferObservable<T> extends Observable<List<T>> {
  final Observable<T> delegate;
  final Scheduler scheduler;
  final Observable trigger;
  final int maxLength;
  final Duration maxAge;

  BufferObservable(
      this.delegate, this.scheduler, this.trigger, this.maxLength, this.maxAge);

  @override
  Subscription subscribe(Observer<List<T>> observer) {
    final subscriber =
        BufferSubscriber<T>(observer, scheduler, trigger, maxLength, maxAge);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class BufferSubscriber<T> extends Subscriber<T>
    implements InnerEvents<T, void> {
  final Scheduler scheduler;
  final int maxLength;
  final Duration maxAge;

  List<T> buffer;
  DateTime bufferBirth;

  BufferSubscriber(Observer<List<T>> observer, this.scheduler,
      Observable trigger, this.maxLength, this.maxAge)
      : super(observer) {
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
