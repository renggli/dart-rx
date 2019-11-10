library rx.constructors.from;

import '../converters/future_to_observable.dart';
import '../converters/iterable_to_observable.dart';
import '../converters/stream_to_observable.dart';
import '../core/observable.dart';
import 'empty.dart';
import 'just.dart';

/// An [Observable] inferred from the `object`s input type.
Observable<T> from<T>(Object object) {
  if (object == null) {
    return empty<T>();
  } else if (object is Observable<T>) {
    return object;
  } else if (object is Iterable<T>) {
    return object.toObservable();
  } else if (object is Future<T>) {
    return object.toObservable();
  } else if (object is Stream<T>) {
    return object.toObservable();
  } else if (object is T) {
    return just<T>(object);
  }
  throw ArgumentError.value(object, 'object');
}
