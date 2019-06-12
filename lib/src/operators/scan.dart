library rx.operators.scan;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef CombineFunction<T, S> = S Function(S accumulator, T value);

/// Combines a sequence of values by repeatedly applying [combine].
Operator<T, T> reduce<T>(CombineFunction<T, T> combine) =>
    (source, destination) =>
        source.subscribe(_ScanSubscriber(destination, combine, false, null));

/// Combines a sequence of values by repeatedly applying [combine], starting
/// with the provided [initialValue].
Operator<T, S> fold<T, S>(S initialValue, CombineFunction<T, S> combine) =>
    (source, destination) => source
        .subscribe(_ScanSubscriber(destination, combine, true, initialValue));

class _ScanSubscriber<T, S> extends Subscriber<T> {
  final CombineFunction<T, S> scanFunction;
  bool hasSeed;
  S seedValue;

  _ScanSubscriber(
      Observer<S> destination, this.scanFunction, this.hasSeed, this.seedValue)
      : super(destination);

  @override
  void onNext(T value) {
    if (hasSeed) {
      seedValue = scanFunction(seedValue, value);
    } else {
      seedValue = value as S;
      hasSeed = true;
    }
    doNext(seedValue);
  }
}
