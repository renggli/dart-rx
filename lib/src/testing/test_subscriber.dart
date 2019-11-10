library rx.testing.test_subscriber;

import '../core/observer.dart';
import '../core/subscriber.dart';
import '../core/subscription.dart';
import 'test_scheduler.dart';

class TestSubscriber<T> extends Subscriber<T> {
  final TestScheduler scheduler;

  final DateTime _subscriptionTimestamp;
  DateTime _unsubscriptionTimestamp;

  TestSubscriber(this.scheduler, Observer<T> destination)
      : _subscriptionTimestamp = scheduler.now,
        super(destination) {
    add(Subscription.create(() => _unsubscriptionTimestamp = scheduler.now));
  }

  /// Timestamp when the observable was subscribed to.
  DateTime get subscriptionTimestamp => _subscriptionTimestamp;

  /// Timestamp when the observable was unsubscribed from.
  DateTime get unsubscriptionTimestamp => _unsubscriptionTimestamp;
}
