library rx.constructors.from;

import 'package:rx/src/constructors/empty.dart';
import 'package:rx/src/constructors/future.dart';
import 'package:rx/src/constructors/iterable.dart';
import 'package:rx/src/constructors/just.dart';
import 'package:rx/src/constructors/stream.dart';
import 'package:rx/src/core/observable.dart';

/// An [Observable] inferred from the `object`s input type.
Observable<T> from<T>(
    /** void|Observable<T>|Iterable<T>|Future<T>|Stream<T>|T */ Object object) {
  if (object == null) {
    return empty<T>();
  } else if (object is Observable<T>) {
    return object;
  } else if (object is Iterable<T>) {
    return fromIterable<T>(object);
  } else if (object is Future<T>) {
    return fromFuture<T>(object);
  } else if (object is Stream<T>) {
    return fromStream<T>(object);
  } else if (object is T) {
    return just<T>(object);
  } else {
    throw ArgumentError.value(object, 'object');
  }
}
