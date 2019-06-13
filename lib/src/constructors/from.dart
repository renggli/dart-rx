library rx.constructors.from;

import 'package:rx/src/constructors/empty.dart';
import 'package:rx/src/constructors/future.dart';
import 'package:rx/src/constructors/iterable.dart';
import 'package:rx/src/constructors/just.dart';
import 'package:rx/src/constructors/stream.dart';
import 'package:rx/src/core/observable.dart';

/// An [Observable] inferred from the `object`s input type.
Observable<T> from<T>(Object object) {
  if (object == null) {
    return empty();
  } else if (object is Observable) {
    return object;
  } else if (object is Iterable) {
    return fromIterable(object);
  } else if (object is Future) {
    return fromFuture(object);
  } else if (object is Stream) {
    return fromStream(object);
  } else {
    return just(object);
  }
}
