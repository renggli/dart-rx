library rx.constructors.defer;

import '../core/observable.dart';
import '../shared/functions.dart';
import 'create.dart';
import 'empty.dart';

/// An [Observable] that uses the `observableFactory` to create a new
/// [Observable] on each subscribe.
Observable<T> defer<T>(Map0<Observable<T>> callback) => create<T>((subscriber) {
      final observable = callback() ?? empty<T>();
      subscriber.add(observable.subscribe(subscriber));
    });
