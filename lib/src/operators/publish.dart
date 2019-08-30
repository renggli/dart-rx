library rx.operators.publish;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/observables/connectable.dart';
import 'package:rx/src/subjects/async_subject.dart';
import 'package:rx/src/subjects/behavior_subject.dart';
import 'package:rx/src/subjects/replay_subject.dart';

import 'multicast.dart';

extension PublishOperator<T> on Observable<T> {
  /// Creates a [ConnectableObservable] that emits its initial or last seen
  /// value to its subscribers.
  ConnectableObservable<T> publishBehavior(T value) =>
    multicast(subject: BehaviorSubject<T>(value));

  /// Creates a [ConnectableObservable] that emits its last value to all its
  /// subscribers on completion.
  ConnectableObservable<T> publishLast() =>
    multicast(subject: AsyncSubject<T>());

  /// Creates a [ConnectableObservable] that replays all its previous values to
  /// new subscribers.
  ConnectableObservable<T> publishReplay({int bufferSize}) =>
    multicast(subject: ReplaySubject<T>(bufferSize: bufferSize));
}