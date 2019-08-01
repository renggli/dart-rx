library rx.operators.scan;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/shared/functions.dart';

/// Combines a sequence of values by repeatedly applying [transform].
OperatorFunction<T, T> reduce<T>(Map2<T, T, T> transform) =>
    (source) => source.lift((source, subscriber) => source
        .subscribe(_ScanSubscriber<T, T>(subscriber, transform, false, null)));

/// Combines a sequence of values by repeatedly applying [transform], starting
/// with the provided [initialValue].
OperatorFunction<T, R> fold<T, R>(R initialValue, Map2<R, T, R> transform) =>
    (source) => source.lift((source, subscriber) => source.subscribe(
        _ScanSubscriber<T, R>(subscriber, transform, true, initialValue)));

class _ScanSubscriber<T, R> extends Subscriber<T> {
  final Map2<R, T, R> transform;
  bool hasSeed;
  R seedValue;

  _ScanSubscriber(
      Observer<R> destination, this.transform, this.hasSeed, this.seedValue)
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
      seedValue = value as R;
      hasSeed = true;
    }
    doNext(seedValue);
  }
}
