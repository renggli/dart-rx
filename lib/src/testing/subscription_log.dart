library rx.testing.subscription_log;

import 'package:rx/src/core/scheduler.dart';
import 'package:rx/subscriptions.dart';

abstract class SubscriptionLog {
  final List<DateTime> subscribed = [];
  final List<DateTime> unsubscribed = [];

  Scheduler get scheduler;

  Subscription logSubscribed() {
    final index = subscribed.length;
    subscribed.add(scheduler.now);
    unsubscribed.add(null);
    return Subscription.create(() => unsubscribed[index] = scheduler.now);
  }
}
