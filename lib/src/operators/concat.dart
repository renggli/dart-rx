library rx.operators.concat;

import 'package:rx/src/constructors/concat.dart';
import 'package:rx/src/constructors/from.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/shared/functions.dart';

/// Prepends the emission of items with [object].
Map1<Observable<T>, Observable<T>> beginWith<T>(
    /** void|Observable<T>|Iterable<T>|Future<T>|Stream<T>|T */ Object object) {
  final observable = from<T>(object);
  return (source) => source.lift((source, subscriber) =>
      concat<T>([observable, source]).subscribe(subscriber));
}

/// Appends the emission of items with [object].
Map1<Observable<T>, Observable<T>> endWith<T>(
    /** void|Observable<T>|Iterable<T>|Future<T>|Stream<T>|T */ Object object) {
  final observable = from<T>(object);
  return (source) => source.lift((source, subscriber) =>
      concat<T>([source, observable]).subscribe(subscriber));
}
