library rx.operators.finalize;

import 'package:rx/src/core/operator.dart';
import 'package:rx/src/shared/functions.dart';
import 'package:rx/subscriptions.dart';

/// Returns an Observable that mirrors the source Observable, but will call a
/// specified function when the source terminates on complete or error.
OperatorFunction<T, T> finalize<T>(CompleteCallback finalize) =>
    (source) => source.lift((source, subscriber) {
          subscriber.add(Subscription.create(finalize));
          return source.subscribe(subscriber);
        });
