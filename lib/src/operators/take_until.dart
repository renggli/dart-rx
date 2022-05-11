import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../observers/inner.dart';

extension TakeUntilOperator<T> on Observable<T> {
  /// Emits values until an [Observable] emits a first value.
  Observable<T> takeUntil<R>(Observable<R> trigger) =>
      TakeUntilObservable<T, R>(this, trigger);
}

class TakeUntilObservable<T, R> implements Observable<T> {
  TakeUntilObservable(this.delegate, this.trigger);

  final Observable<T> delegate;
  final Observable<R> trigger;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = TakeUntilSubscriber<T, R>(observer, trigger);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TakeUntilSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  TakeUntilSubscriber(Observer<T> super.observer, this.trigger) {
    add(InnerObserver<R, void>(this, trigger, null));
  }

  final Observable<R> trigger;

  @override
  void notifyNext(Disposable disposable, void state, R value) => doComplete();

  @override
  void notifyError(Disposable disposable, void state, Object error,
          StackTrace stackTrace) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) {}
}
