import 'package:meta/meta.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import 'test_event_sequence.dart';
import 'test_scheduler.dart';
import 'test_subscriber.dart';

abstract class TestObservable<T> implements Observable<T> {
  TestObservable(this.scheduler, this.sequence);

  final TestScheduler scheduler;

  final TestEventSequence<T> sequence;

  @protected
  TestSubscriber<T> createSubscriber(Observer<T> observer) {
    final subscriber = TestSubscriber<T>(scheduler, observer);
    scheduler.subscribers.add(subscriber);
    return subscriber;
  }
}
