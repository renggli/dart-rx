library rx.subscriptions.stateful;

import 'package:rx/src/core/subscription.dart';

class StatefulSubscription extends Subscription {
  bool _isClosed = false;

  StatefulSubscription();

  @override
  bool get isClosed => _isClosed;

  @override
  void unsubscribe() => _isClosed = true;
}
