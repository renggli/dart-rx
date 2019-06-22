library rx.testing.test_observable;

import 'package:meta/meta.dart';
import 'package:rx/core.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/testing/test_event_sequence.dart';

import 'test_scheduler.dart';
import 'test_subscriber.dart';

abstract class TestObservable<T> extends Observable<T> {
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
}
