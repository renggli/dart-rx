library rx.core.subscription;

import 'package:rx/src/subscriptions/anonymous.dart';
import 'package:rx/src/subscriptions/empty.dart';

abstract class Subscription {
  const Subscription();

  /// Creates a [Subscription] that invokes the specified action when
  /// unsubscribed.
  factory Subscription.create(UnsubscribeAction unsubscribeAction) =>
      AnonymousSubscription(unsubscribeAction);

  /// Creates a [Subscription] that does nothing when unsubscribed.
  factory Subscription.empty() => const EmptySubscription();

  /// Returns true, if this [Subscription] is no longer active.
  bool get isClosed;

  /// Disposes the resources held by this [Subscription].
  void unsubscribe();
}
