import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension WhereTypeOperator<T> on Observable<T> {
  /// Filter items emitted by the source Observable by only emitting those that
  /// are of the specified type.
  Observable<R> whereType<R>() => WhereTypeObserver<T, R>(this);
}

class WhereTypeObserver<T, R> implements Observable<R> {
  WhereTypeObserver(this.delegate);

  final Observable<T> delegate;

  @override
  Disposable subscribe(Observer<R> observer) {
    final subscriber = WhereTypeSubscriber<T, R>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class WhereTypeSubscriber<T, R> extends Subscriber<T> {
  WhereTypeSubscriber(Observer<R> super.observer);

  @override
  void onNext(T value) {
    if (value is R) {
      doNext(value);
    }
  }
}
