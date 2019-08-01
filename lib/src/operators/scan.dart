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
OperatorFunction<T, S> fold<T, S>(S initialValue, Map2<S, T, S> transform) =>
    (source) => source.lift((source, subscriber) => source.subscribe(
        _ScanSubscriber<T, S>(subscriber, transform, true, initialValue)));

class _ScanSubscriber<T, S> extends Subscriber<T> {
  final Map2<S, T, S> transform;
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
