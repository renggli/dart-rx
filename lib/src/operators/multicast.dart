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
  if (subject == null && factory == null) {
    throw ArgumentError.notNull('subject');
  } else if (subject != null && factory != null) {
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

/// Creates a [ConnectableObservable] that waits until its [connect] is called
/// before it begins emitting items to all subscribers.
OperatorFunction<T, R> publish<T, R>(
        {Map1<Observable<T>, Observable<R>> selector}) =>
    selector == null
        ? multicast<T, R>(subject: Subject<T>())
        : multicast<T, R>(factory: () => Subject<T>(), selector: selector);

/// Creates a [ConnectableObservable] that emits its initial or last seen value
/// to its subscribers.
OperatorFunction<T, T> publishBehavior<T>(T value) =>
    (source) => multicast<T, T>(subject: BehaviorSubject<T>(value))(source);

/// Creates a [ConnectableObservable] that emits its last value to all its
/// subscribers on completion.
OperatorFunction<T, T> publishLast<T>() =>
    (source) => multicast<T, T>(subject: AsyncSubject<T>())(source);

/// Creates a [ConnectableObservable] that replays all its previous values to
/// new subscribers.
OperatorFunction<T, T> publishReplay<T>({int bufferSize}) => (source) =>
    multicast<T, T>(subject: ReplaySubject<T>(bufferSize: bufferSize))(source);
