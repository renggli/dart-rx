library rx.operators.multicast;

import 'package:rx/observables.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/subject.dart';
import 'package:rx/src/shared/functions.dart';

/// Returns an multicast observable that shares the underlying stream.
Map1<Observable<T>, ConnectableObservable<T>> multicast<T>(
    {Subject<T> subject, Map0<Subject<T>> factory}) {
  if (subject != null && factory != null) {
    throw ArgumentError.value(
        subject, 'subject', 'Subject and factory cannot both be given.');
  }
  factory ??= () => subject ?? Subject<T>();
  return (source) => ConnectableObservable<T>(source, factory);
}
