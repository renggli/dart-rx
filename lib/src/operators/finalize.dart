library rx.operators.finalize;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/shared/functions.dart';
import 'package:rx/src/subscriptions/anonymous.dart';

/// Returns an Observable that mirrors the source Observable, but will call a
/// specified function when the source terminates on complete or error.
Map1<Observable<T>, Observable<T>> finalize<T>(CompleteCallback finalize) =>
    (source) => source.lift((source, subscriber) {
          subscriber.add(AnonymousSubscription(finalize));
          return source.subscribe(subscriber);
        });
