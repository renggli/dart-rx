library rx.operators.publish;

import 'package:rx/observables.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/shared/functions.dart';
import 'package:rx/src/subjects/async_subject.dart';
import 'package:rx/src/subjects/behavior_subject.dart';
import 'package:rx/src/subjects/replay_subject.dart';

import 'multicast.dart';

/// Creates a [ConnectableObservable] that emits its initial or last seen value
/// to its subscribers.
Map1<Observable<T>, ConnectableObservable<T>> publishBehavior<T>(T value) =>
    (source) => multicast<T>(subject: BehaviorSubject<T>(value))(source);

/// Creates a [ConnectableObservable] that emits its last value to all its
/// subscribers on completion.
Map1<Observable<T>, ConnectableObservable<T>> publishLast<T>() =>
    (source) => multicast<T>(subject: AsyncSubject<T>())(source);

/// Creates a [ConnectableObservable] that replays all its previous values to
/// new subscribers.
Map1<Observable<T>, ConnectableObservable<T>> publishReplay<T>(
        {int bufferSize}) =>
    (source) =>
        multicast<T>(subject: ReplaySubject<T>(bufferSize: bufferSize))(source);
