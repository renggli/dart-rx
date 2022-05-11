import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';
import '../schedulers/scheduler.dart';
import '../schedulers/settings.dart';

extension BufferOperator<T> on Observable<T> {
  /// Gathers the items emitted by this [Observable] and bundles these items
  /// into a list until either
  ///
  /// - another [Observable] [trigger]s,
  /// - the buffer reaches [maxLength], or
  /// - the buffer reaches [maxAge].
  ///
  Observable<List<T>> buffer<R>(
          {Scheduler? scheduler,
          Observable<R>? trigger,
          int? maxLength,
          Duration? maxAge}) =>
      BufferObservable<T, R>(
          this, scheduler ?? defaultScheduler, trigger, maxLength, maxAge);
}

class BufferObservable<T, R> implements Observable<List<T>> {
  BufferObservable(
      this.delegate, this.scheduler, this.trigger, this.maxLength, this.maxAge);

  final Observable<T> delegate;
  final Scheduler scheduler;
  final Observable<R>? trigger;
  final int? maxLength;
  final Duration? maxAge;

  @override
  Disposable subscribe(Observer<List<T>> observer) {
    final subscriber =
        BufferSubscriber<T, R>(observer, scheduler, trigger, maxLength, maxAge);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class BufferSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  BufferSubscriber(Observer<List<T>> super.observer, this.scheduler,
      Observable<R>? trigger, this.maxLength, this.maxAge) {
    reset();
    if (trigger != null) {
      add(InnerObserver<R, void>(this, trigger, null));
    }
  }

  final Scheduler scheduler;
  final int? maxLength;
  final Duration? maxAge;

  List<T> buffer = const [];
  DateTime? bufferBirth;

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
  void notifyNext(Disposable disposable, void state, R value) => flush();

  @override
  void notifyError(Disposable disposable, void state, Object error,
          StackTrace stackTrace) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) {}

  bool get shouldFlush =>
      (maxLength != null && maxLength! <= buffer.length) ||
      (maxAge != null &&
          bufferBirth != null &&
          bufferBirth!.add(maxAge!).isBefore(scheduler.now));

  void flush() {
    if (buffer.isNotEmpty) {
      doNext(buffer);
      reset();
    }
  }

  void reset() {
    buffer = [];
    bufferBirth = null;
  }
}
