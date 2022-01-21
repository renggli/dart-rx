import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/action.dart';
import 'test_scheduler.dart';

class TestSubscriber<T> extends Subscriber<T> {
  TestSubscriber(this.scheduler, Observer<T> destination)
      : _subscriptionTimestamp = scheduler.now,
        super(destination) {
    add(ActionDisposable(() => _unsubscriptionTimestamp = scheduler.now));
  }

  final TestScheduler scheduler;
  final DateTime _subscriptionTimestamp;
  DateTime? _unsubscriptionTimestamp;

  /// Timestamp when the observable was subscribed to.
  DateTime get subscriptionTimestamp => _subscriptionTimestamp;

  /// Timestamp when the observable was unsubscribed from.
  DateTime get unsubscriptionTimestamp => _unsubscriptionTimestamp == null
      ? throw StateError('Subscriber is not disposed')
      : _unsubscriptionTimestamp!;
}
