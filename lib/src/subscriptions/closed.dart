library rx.subscriptions.closed;

import 'package:rx/src/core/subscription.dart';

class ClosedSubscription extends Subscription {
  const ClosedSubscription();

  @override
  bool get isClosed => true;

  @override
  void unsubscribe() {}
}
