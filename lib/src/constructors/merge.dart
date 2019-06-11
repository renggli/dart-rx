library rx.constructors.merge;

import 'package:rx/core.dart';
import 'package:rx/src/constructors/create.dart';
import 'package:rx/src/constructors/empty.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/subscriptions/composite.dart';

/// Creates an [Observable] which concurrently emits all values from every
/// source [Observable].
Observable<T> merge<T>(List<Observable<T>> sources) => sources.isEmpty
    ? empty()
    : create((subscriber) {
        var completed = 0;
        final subscription = CompositeSubscription();
        for (var i = 0; i < sources.length; i++) {
          subscription.add(sources[i].subscribe(Observer(
            next: (value) => subscriber.next(value),
            error: (error, [stackTrace]) {
              subscriber.error(error, stackTrace);
              subscription.unsubscribe();
            },
            complete: () {
              completed++;
              if (completed == sources.length) {
                subscriber.complete();
                subscription.unsubscribe();
              }
            },
          )));
        }
        return subscription;
      });
