library rx.subscriptions.emtpy;

import '../core/subscription.dart';

class EmptySubscription extends Subscription {
  const EmptySubscription();

  @override
  bool get isClosed => true;

  @override
  void unsubscribe() {}
}
