library rx.core.errors;

import 'package:rx/src/core/subscription.dart';

/// An error thrown when one or more errors have occurred during the
/// `unsubscribe` of a [Subscription].
class UnsubscribedError extends Error {
  static void checkOpen(Subscription subscription) {
    if (subscription.isClosed) {
      throw UnsubscribedError();
    }
  }
}
