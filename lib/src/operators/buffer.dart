library rx.operators.buffer;

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';
import '../schedulers/scheduler.dart';
import '../schedulers/settings.dart';

extension BufferOperator<T> on Observable<T> {
  /// Gathers the items emitted by this [Observable] and bundles these items
  /// into a list when the buffer reaches a [maxLength], when the buffer reaches
  /// a [maxAge], or when another [Observable] [trigger]s.
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
  Disposable subscribe(Observer<List<T>> observer) {
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
      add(InnerObserver(this, trigger));
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
  void notifyNext(Disposable disposable, void state, T value) => flush();

  @override
  void notifyError(Disposable disposable, void state, Object error,
          [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) {}

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
