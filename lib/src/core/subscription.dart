library rx.core.subscription;

import 'package:rx/src/core/functions.dart';
import 'package:rx/src/subscriptions/anonymous.dart';
import 'package:rx/src/subscriptions/empty.dart';

abstract class Subscription {
  const Subscription();

  /// Creates a [Subscription] for the provided teardown logic.
  factory Subscription.of(Object tearDownLogic) {
    if (tearDownLogic == null) {
      return Subscription.empty();
    } else if (tearDownLogic is Subscription) {
      return tearDownLogic;
    } else if (tearDownLogic is CompleteCallback) {
      return Subscription.create(tearDownLogic);
    } else {
      throw ArgumentError.value('tearDownLogic', tearDownLogic);
    }
  }

  /// Creates a [Subscription] that invokes the specified action when
  /// unsubscribed.
  factory Subscription.create(CompleteCallback unsubscribeAction) =>
      AnonymousSubscription(unsubscribeAction);

  /// Creates a [Subscription] that is already closed.
  factory Subscription.empty() => const EmptySubscription();

  /// Returns true, if this [Subscription] is no longer active.
  bool get isClosed;

  /// Disposes the resources held by this [Subscription].
  void unsubscribe();
}
