library rx.operators.where_type;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Filter items emitted by the source Observable by only emitting those that
/// are of the specified type.
OperatorFunction<T, R> whereType<T, R>() =>
    (source) => source.lift<R>((source, subscriber) =>
        source.subscribe(_WhereTypeSubscriber<T, R>(subscriber)));

class _WhereTypeSubscriber<T, R> extends Subscriber<T> {
  _WhereTypeSubscriber(Observer<R> destination) : super(destination);

  @override
  void onNext(T value) {
    if (value is R) {
      doNext(value);
    }
  }
}
