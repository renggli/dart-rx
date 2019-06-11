library rx.subscriptions.emtpy;

import 'package:rx/src/core/subscription.dart';

class EmptySubscription extends Subscription {
  const EmptySubscription();

  @override
  bool get isClosed => true;

  @override
  void unsubscribe() {}
}
