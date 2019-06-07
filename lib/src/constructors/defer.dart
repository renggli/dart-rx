library rx.constructors.defer;

import 'package:rx/src/constructors/create.dart';
import 'package:rx/src/constructors/empty.dart';
import 'package:rx/src/core/observable.dart';

typedef ObservableFactory<T> = Observable<T> Function();

/// An [Observable] that uses the `observableFactory` to create a new
/// [Observable] on each subscribe.
Observable<T> defer<T>(ObservableFactory<T> observableFactory) =>
    create<T>((subscriber) {
      try {
        final observable = observableFactory() ?? empty();
        subscriber.add(observable.subscribe(subscriber));
      } catch (error, stackTrace) {
        subscriber.error(error, stackTrace);
      }
    });
