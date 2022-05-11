import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';

extension SkipUntilOperator<T> on Observable<T> {
  /// Skips over all values until an [Observable] emits a first value.
  Observable<T> skipUntil<R>(Observable<R> trigger) =>
      SkipUntilObservable<T, R>(this, trigger);
}

class SkipUntilObservable<T, R> implements Observable<T> {
  SkipUntilObservable(this.delegate, this.trigger);

  final Observable<T> delegate;
  final Observable<R> trigger;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = SkipUntilSubscriber<T, R>(observer, trigger);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SkipUntilSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  SkipUntilSubscriber(Observer<T> super.observer, this.trigger) {
    add(InnerObserver<R, void>(this, trigger, null));
  }

  final Observable<R> trigger;
  bool taking = false;

  @override
  void onNext(T value) {
    if (taking) {
      doNext(value);
    }
  }

  @override
  void notifyNext(Disposable disposable, void state, R value) => taking = true;

  @override
  void notifyError(Disposable disposable, void state, Object error,
          StackTrace stackTrace) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) {}
}
