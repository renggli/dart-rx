library rx.constructors.defer;

import 'package:rx/src/constructors/create.dart';
import 'package:rx/src/constructors/empty.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/shared/functions.dart';

/// An [Observable] that uses the `observableFactory` to create a new
/// [Observable] on each subscribe.
Observable<T> defer<T>(Map0<Observable<T>> callback) => create<T>((subscriber) {
      final observable = callback() ?? empty<T>();
      subscriber.add(observable.subscribe(subscriber));
      return subscriber;
    });
