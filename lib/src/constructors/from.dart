library rx.constructors.from;

import 'package:rx/src/constructors/future.dart';
import 'package:rx/src/constructors/iterable.dart';
import 'package:rx/src/constructors/stream.dart';
import 'package:rx/src/core/observable.dart';

extension FromConstructor on Observable {
  /// An [Observable] inferred from the `object`s input type.
  static Observable<T> from<T>(
      /** void|Observable<T>|Iterable<T>|Future<T>|Stream<T>|T */ Object
          object) {
    if (object == null) {
      return Observable.empty<T>();
    } else if (object is Observable<T>) {
      return object;
    } else if (object is Iterable<T>) {
      return object.toObservable();
    } else if (object is Future<T>) {
      return object.toObservable();
    } else if (object is Stream<T>) {
      return object.toObservable();
    } else if (object is T) {
      return Observable.just<T>(object);
    } else {
      throw ArgumentError.value(object, 'object');
    }
  }
}
