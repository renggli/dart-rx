library rx.operators.scan;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';

typedef CombineFunction<T, S> = S Function(S accumulator, T value);

/// Combines a sequence of values by repeatedly applying [combine].
Operator<T, T> reduce<T>(CombineFunction<T, T> combine) =>
    _ScanOperator(combine, false, null);

/// Combines a sequence of values by repeatedly applying [combine], starting
/// with the provided [initialValue].
Operator<T, S> fold<T, S>(S initialValue, CombineFunction<T, S> combine) =>
    _ScanOperator(combine, true, initialValue);

class _ScanOperator<T, S> implements Operator<T, S> {
  final CombineFunction<T, S> scanFunction;
  final bool hasSeed;
  final S seedValue;

  _ScanOperator(this.scanFunction, this.hasSeed, this.seedValue);

  @override
  Subscription call(Observable<T> source, Observer<S> destination) =>
      source.subscribe(
          _ScanSubscriber(destination, scanFunction, hasSeed, seedValue));
}

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
    destination.next(seedValue);
  }
}
