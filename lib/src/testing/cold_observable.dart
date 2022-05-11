import '../core/observer.dart';
import '../disposables/disposable.dart';
import 'test_observable.dart';

class ColdObservable<T> extends TestObservable<T> {
  ColdObservable(super.scheduler, super.sequence);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = createSubscriber(observer);
    for (final event in sequence.events) {
      final timestamp = scheduler.now.add(scheduler.stepDuration * event.index);
      scheduler.scheduleAbsolute(timestamp, () => event.observe(subscriber));
    }
    return subscriber;
  }

  @override
  String toString() => 'ColdObservable<$T>{${sequence.toMarbles()}}';
}
