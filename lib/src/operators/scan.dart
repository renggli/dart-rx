library rx.operators.scan;

import 'package:rx/core.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';

typedef ScanTransform<T, S> = S Function(S accumulator, T value);

/// Combines a sequence of values by repeatedly applying [transform].
Operator<T, T> reduce<T>(ScanTransform<T, T> transform) =>
    (subscriber, source) =>
        source.subscribe(_ScanSubscriber(subscriber, transform, false, null));

/// Combines a sequence of values by repeatedly applying [transform], starting
/// with the provided [initialValue].
Operator<T, S> fold<T, S>(S initialValue, ScanTransform<T, S> transform) =>
    (subscriber, source) => source
        .subscribe(_ScanSubscriber(subscriber, transform, true, initialValue));

class _ScanSubscriber<T, S> extends Subscriber<T> {
  final ScanTransform<T, S> transform;
  bool hasSeed;
  S seedValue;

  _ScanSubscriber(
      Observer<S> destination, this.transform, this.hasSeed, this.seedValue)
      : super(destination);

  @override
  void onNext(T value) {
    if (hasSeed) {
      final transformEvent = Event.map2(transform, seedValue, value);
      if (transformEvent is ErrorEvent) {
        doError(transformEvent.error, transformEvent.stackTrace);
      } else {
        seedValue = transformEvent.value;
      }
    } else {
      seedValue = value as S;
      hasSeed = true;
    }
    doNext(seedValue);
  }
}
