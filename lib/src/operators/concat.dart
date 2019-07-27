library rx.operators.concat;

import 'package:rx/src/constructors/concat.dart';
import 'package:rx/src/constructors/from.dart';
import 'package:rx/src/core/operator.dart';

/// Prepends the emission of items with [object].
Operator<T, T> beginWith<T>(
    /** void|Observable<T>|Iterable<T>|Future<T>|Stream<T>|T */ Object object) {
  final observable = from<T>(object);
  return (subscriber, source) =>
      concat<T>([observable, source]).subscribe(subscriber);
}

/// Appends the emission of items with [object].
Operator<T, T> endWith<T>(
    /** void|Observable<T>|Iterable<T>|Future<T>|Stream<T>|T */ Object object) {
  final observable = from<T>(object);
  return (subscriber, source) =>
      concat<T>([source, observable]).subscribe(subscriber);
}
