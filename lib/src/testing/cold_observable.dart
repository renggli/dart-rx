import '../core/observer.dart';
import '../disposables/disposable.dart';
import 'test_event_sequence.dart';
import 'test_observable.dart';
import 'test_scheduler.dart';

class ColdObservable<T> extends TestObservable<T> {
  ColdObservable(TestScheduler scheduler, TestEventSequence<T> sequence)
      : super(scheduler, sequence);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = createSubscriber(observer);
    for (final event in sequence.events) {
      final timestamp = scheduler.now.add(scheduler.stepDuration * event.index);
      scheduler.scheduleAbsolute(timestamp, () => event.observe(subscriber));
    }
    return subscriber;
  }
}
