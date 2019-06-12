library rx.operators.last;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

/// Returns the last element of an observable sequence.
Operator<T, T> last<T>() =>
    (source, destination) => source.subscribe(_LastSubscriber(destination));

class _LastSubscriber<T> extends Subscriber<T> {
  T lastValue;
  bool seenValue = false;

  _LastSubscriber(Observer<T> destination) : super(destination);

  @override
  void onNext(T value) {
    lastValue = value;
    seenValue = true;
  }

  @override
  void onComplete() {
    if (seenValue) {
      doNext(lastValue);
      doComplete();
    } else {
      doError('Sequence contains no elements');
    }
  }
}
