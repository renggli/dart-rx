import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/errors.dart';
import '../events/event.dart';

extension DematerializeOperator<T> on Observable<Event<T>> {
  /// Dematerialize events of this [Observable] into from a sequence of
  /// [Event] objects.
  Observable<T> dematerialize() => DematerializeObservable<T>(this);
}

class DematerializeObservable<T> implements Observable<T> {
  DematerializeObservable(this.delegate);

  final Observable<Event<T>> delegate;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = DematerializeSubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class DematerializeSubscriber<T> extends Subscriber<Event<T>> {
  DematerializeSubscriber(Observer<T> super.observer);

  @override
  void onNext(Event<T> value) {
    if (value.isNext) {
      doNext(value.value);
    } else if (value.isError) {
      doError(value.error, value.stackTrace);
    } else if (value.isComplete) {
      doComplete();
    } else {
      doError(UnexpectedEventError(value), StackTrace.current);
    }
  }
}
