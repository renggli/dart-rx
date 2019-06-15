library rx.operators.skip_while;

import 'package:rx/core.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';

/// Function implementing condition of the [skipWhile] operator.
typedef SkipWhilePredicate<T> = bool Function(T value);

/// Skips over the values while the [predicate] is `true`.
Operator<T, T> skipWhile<T>(SkipWhilePredicate predicate) =>
    (subscriber, source) =>
        source.subscribe(_SkipWhileSubscriber(subscriber, predicate));

class _SkipWhileSubscriber<T> extends Subscriber<T> {
  final SkipWhilePredicate predicate;
  bool skipping = true;

  _SkipWhileSubscriber(Observer<T> destination, this.predicate)
      : super(destination);

  @override
  void onNext(T value) {
    if (skipping) {
      final predicateEvent = Event.map1(predicate, value);
      if (predicateEvent is ErrorEvent) {
        doError(predicateEvent.error, predicateEvent.stackTrace);
      } else if (!predicateEvent.value) {
        skipping = false;
        doNext(value);
      }
    } else {
      doNext(value);
    }
  }
}
