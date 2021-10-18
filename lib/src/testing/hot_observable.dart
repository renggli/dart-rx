import 'package:meta/meta.dart';

import '../core/observer.dart';
import '../disposables/disposable.dart';
import '../subjects/subject.dart';
import 'test_event_sequence.dart';
import 'test_events.dart';
import 'test_observable.dart';
import 'test_scheduler.dart';

class HotObservable<T> extends TestObservable<T> {
  @protected
  final Subject<T> subject = Subject<T>();

  HotObservable(TestScheduler scheduler, TestEventSequence<T> sequence)
      : super(scheduler, sequence) {
    final subscriptionIndex = sequence.events
        .where((element) => element.event is SubscribeEvent)
        .map((element) => element.index)
        .firstWhere((index) => true, orElse: () => 0);
    for (final event in sequence.events) {
      final timestamp = scheduler.now
          .add(scheduler.stepDuration * (event.index - subscriptionIndex));
      scheduler.scheduleAbsolute(timestamp, () => event.observe(subject));
    }
  }

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = createSubscriber(observer);
    subject.subscribe(subscriber);
    return subscriber;
  }

  @override
  String toString() => 'HotObservable<$T>{${sequence.toMarbles()}}';
}
