import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension TapOperator<T> on Observable<T> {
  /// Perform a side effect for every emission on the source.
  Observable<T> tap(Observer<T> handler) => TapObservable<T>(this, handler);
}

class TapObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final Observer<T> handler;

  TapObservable(this.delegate, this.handler);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = TapSubscriber<T>(observer, handler);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class TapSubscriber<T> extends Subscriber<T> {
  final Observer<T> handler;

  TapSubscriber(Observer<T> observer, this.handler) : super(observer);

  @override
  void onNext(T value) {
    try {
      handler.next(value);
    } catch (error, stackTrace) {
      doError(error, stackTrace);
      return;
    }
    doNext(value);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    try {
      handler.error(error, stackTrace);
    } catch (error, stackTrace) {
      doError(error, stackTrace);
      return;
    }
    doError(error, stackTrace);
  }

  @override
  void onComplete() {
    try {
      handler.complete();
    } catch (error, stackTrace) {
      doError(error, stackTrace);
      return;
    }
    doComplete();
  }
}
