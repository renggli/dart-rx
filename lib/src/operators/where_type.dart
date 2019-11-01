library rx.operators.where_type;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

extension WhereTypeOperator<T> on Observable<T> {
  /// Filter items emitted by the source Observable by only emitting those that
  /// are of the specified type.
  Observable<R> whereType<R>() => WhereTypeObserver<T, R>(this);
}

class WhereTypeObserver<T, R> extends Observable<R> {
  final Observable<T> delegate;

  WhereTypeObserver(this.delegate);

  @override
  Subscription subscribe(Observer<R> observer) {
    final subscriber = WhereTypeSubscriber<T, R>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class WhereTypeSubscriber<T, R> extends Subscriber<T> {
  WhereTypeSubscriber(Observer<R> observer) : super(observer);

  @override
  void onNext(T value) {
    if (value is R) {
      doNext(value);
    }
  }
}
