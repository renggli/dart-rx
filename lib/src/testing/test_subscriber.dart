library rx.testing.test_subscriber;

import 'package:rx/core.dart';
import 'package:rx/subscriptions.dart';

import 'test_scheduler.dart';

class TestSubscriber<T> extends Subscriber<T> {
  final TestScheduler scheduler;

  final DateTime _subscriptionTimestamp;
  DateTime _unsubscriptionTimestamp;

  TestSubscriber(this.scheduler, Observer<T> destination)
      : _subscriptionTimestamp = scheduler.now,
        super(destination) {
    add(AnonymousSubscription(() => _unsubscriptionTimestamp = scheduler.now));
  }

  /// Timestamp when the observable was subscribed to.
  DateTime get subscriptionTimestamp => _subscriptionTimestamp;

  /// Timestamp when the observable was unsubscribed from.
  DateTime get unsubscriptionTimestamp => _unsubscriptionTimestamp;
}
