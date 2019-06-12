library rx.operators.finalize;

import 'package:rx/src/core/operator.dart';
import 'package:rx/src/subscriptions/anonymous.dart';

typedef FinalizeFunction = void Function();

/// Returns an Observable that mirrors the source Observable, but will call a
/// specified function when the source terminates on complete or error.
Operator<T, T> finalize<T>(FinalizeFunction finalize) => (subscriber, source) {
      subscriber.add(AnonymousSubscription(finalize));
      return source.subscribe(subscriber);
    };
