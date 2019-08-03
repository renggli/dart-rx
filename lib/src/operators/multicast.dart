library rx.operators.multicast;

import 'package:rx/observables.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/subject.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

/// Returns an multicast observable that shares the underlying stream.
Map1<Observable<T>, ConnectableObservable<R>> multicast<T, R>({
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
            selector(subject).subscribe(subscriber as Subject<R>),
            source.subscribe(subject),
          ]);
        });
}
