library rx.testing.hot_observable;

import 'package:rx/core.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/testing/subscription_log.dart';
import 'package:rx/src/testing/test_events.dart';
import 'package:rx/src/testing/test_scheduler.dart';

class HotObservable<T> extends Subject<T> with SubscriptionLog {
  final TestScheduler scheduler;
  final List<TestEvent<T>> events;
  final SubscribeEvent<T> subscribeEvent;

  HotObservable(this.scheduler, this.events)
      : subscribeEvent = events
            .whereType<SubscribeEvent>()
            .firstWhere((element) => true, orElse: () => null);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = Subscriber<T>(observer);
    final offset = subscribeEvent == null ? 0 : subscribeEvent.index;
    for (final event in events) {
      final timestamp =
          scheduler.now.add(scheduler.tickDuration * (event.index - offset));
      scheduler.scheduleAbsolute(timestamp, () => event.observe(subscriber));
    }
    subscriber.add(logSubscribed());
    subscriber.add(super.subscribe(observer));
    return subscriber;
  }
}
