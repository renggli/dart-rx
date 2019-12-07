library rx.operators.materialize;

import '../core/events.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

extension MaterializeOperator<T> on Observable<T> {
  /// Materializes the events of this [Observable] as [Event] objects:
  /// [NextEvent], [ErrorEvent] and [CompleteEvent].
  Observable<Event<T>> materialize() => MaterializeObservable<T>(this);
}

class MaterializeObservable<T> extends Observable<Event<T>> {
  final Observable<T> delegate;

  MaterializeObservable(this.delegate);

  @override
  Disposable subscribe(Observer<Event<T>> observer) {
    final subscriber = MaterializeSubscriber<T>(observer);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class MaterializeSubscriber<T> extends Subscriber<T> {
  MaterializeSubscriber(Observer<Event<T>> destination) : super(destination);

  @override
  void onNext(T value) => doNext(Event<T>.next(value));

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    doNext(Event<T>.error(error, stackTrace));
    doComplete();
  }

  @override
  void onComplete() {
    doNext(Event<T>.complete());
    doComplete();
  }
}
