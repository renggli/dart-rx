library rx.constructors.from;

import 'package:rx/src/constructors/empty.dart';
import 'package:rx/src/constructors/future.dart';
import 'package:rx/src/constructors/iterable.dart';
import 'package:rx/src/constructors/just.dart';
import 'package:rx/src/constructors/stream.dart';
import 'package:rx/src/core/observable.dart';

/// An [Observable] inferred from the input [object].
Observable<T> from<T>(Object value) {
  if (value == null) {
    return empty();
  } else if (value is Observable) {
    return value;
  } else if (value is Iterable) {
    return fromIterable(value);
  } else if (value is Future) {
    return fromFuture(value);
  } else if (value is Stream) {
    return fromStream(value);
  } else {
    return just(value);
  }
}
