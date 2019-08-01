library rx.operators.multicast;

import 'package:rx/observables.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/operator.dart';
import 'package:rx/src/core/subject.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';
import 'package:rx/src/subjects/async_subject.dart';
import 'package:rx/src/subjects/behavior_subject.dart';
import 'package:rx/src/subjects/replay_subject.dart';

/// Returns an multicast observable that shares the underlying stream.
OperatorFunction<T, R> multicast<T, R>({
  Subject<T> subject,
  Map0<Subject<T>> factory,
  Map1<Observable<T>, Observable<R>> selector,
}) {
  if (subject != null && factory != null) {
    throw ArgumentError.value(
        subject, 'subject', 'Subject and factory cannot both be given.');
  }
  final subjectFactory = factory ?? () => subject ?? Subject<T>();
  return (source) => selector == null
      ? ConnectableObservable<T>(source, subjectFactory)
      : source.lift((source, subscriber) {
          final subject = subjectFactory();
          return Subscription.composite([
            selector(subject).subscribe(subscriber),
            source.subscribe(subject),
          ]);
        });
}

OperatorFunction<T, T> publishBehavior<T>(T value) =>
    multicast<T, T>(factory: () => BehaviorSubject<T>(value));

OperatorFunction<T, T> publishLast<T>() =>
    multicast<T, T>(factory: () => AsyncSubject<T>());

OperatorFunction<T, T> publishReplay<T>({int bufferSize}) =>
    multicast<T, T>(factory: () => ReplaySubject<T>(bufferSize: bufferSize));
