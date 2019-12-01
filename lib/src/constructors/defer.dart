library rx.constructors.defer;

import '../core/observable.dart';
import '../shared/functions.dart';
import 'create.dart';
import 'empty.dart';

/// Creates an [Observable] that uses the provided `callback` to create a new
/// [Observable] on each subscribe.
Observable<T> defer<T>(Map0<Observable<T>> callback) => create<T>((emitter) {
      final observable = callback() ?? empty<T>();
      emitter.add(observable.subscribe(emitter));
    });
