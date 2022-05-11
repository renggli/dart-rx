import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../events/event.dart';

extension MaterializeOperator<T> on Observable<T> {
  /// Materializes the events of this [Observable] as [Event] objects.
  Observable<Event<T>> materialize() => MaterializeObservable<T>(this);
}

class MaterializeObservable<T> implements Observable<Event<T>> {
  MaterializeObservable(this.delegate);

  final Observable<T> delegate;

  @override
  Disposable subscribe(Observer<Event<T>> observer) {
    final subscriber = MaterializeSubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class MaterializeSubscriber<T> extends Subscriber<T> {
  MaterializeSubscriber(Observer<Event<T>> super.destination);

  @override
  void onNext(T value) => doNext(Event<T>.next(value));

  @override
  void onError(Object error, StackTrace stackTrace) {
    doNext(Event<T>.error(error, stackTrace));
    doComplete();
  }

  @override
  void onComplete() {
    doNext(Event<T>.complete());
    doComplete();
  }
}
