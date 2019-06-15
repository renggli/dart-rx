library rx.operators.skip_while;

import 'package:rx/core.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';

/// Function implementing condition of the [skipWhile] operator.
typedef SkipWhileCondition<T> = bool Function(T value);

/// Skips over the values while the [condition] is `true`.
Operator<T, T> skipWhile<T>(SkipWhileCondition condition) =>
    (subscriber, source) =>
        source.subscribe(_SkipWhileSubscriber(subscriber, condition));

class _SkipWhileSubscriber<T> extends Subscriber<T> {
  final SkipWhileCondition condition;
  bool skipping = true;

  _SkipWhileSubscriber(Observer<T> destination, this.condition)
      : super(destination);

  @override
  void onNext(T value) {
    if (skipping) {
      final notification = Notification.map(value, condition);
      if (notification is ErrorNotification) {
        doError(notification.error, notification.stackTrace);
      } else if (!notification.value) {
        skipping = false;
        doNext(value);
      }
    } else {
      doNext(value);
    }
  }
}
