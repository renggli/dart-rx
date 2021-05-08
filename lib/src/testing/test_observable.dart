import 'package:meta/meta.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import 'test_event_sequence.dart';
import 'test_scheduler.dart';
import 'test_subscriber.dart';

abstract class TestObservable<T> with Observable<T> {
  @protected
  final TestScheduler scheduler;

  @protected
  final TestEventSequence<T> sequence;

  @protected
  final List<TestSubscriber<T>> subscribers = [];

  TestObservable(this.scheduler, this.sequence);

  @protected
  TestSubscriber<T> createSubscriber(Observer<T> observer) {
    final subscriber = TestSubscriber<T>(scheduler, observer);
    subscribers.add(subscriber);
    return subscriber;
  }

  @override
  String toString() => '${super.toString()}{${sequence.toMarbles()}';
}
