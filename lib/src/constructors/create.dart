library rx.constructors.create;

import '../core/events.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

/// Creates an observable sequence from a specified subscribe method
/// implementation.
Observable<T> create<T>(Map1<Subscriber<T>, dynamic> subscribeFunction) =>
    CreateObservable<T>(subscribeFunction);

class CreateObservable<T> extends Observable<T> {
  final Map1<Subscriber<T>, dynamic> callback;

  CreateObservable(this.callback);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = Subscriber<T>(observer);
    final event = Event.map1(callback, subscriber);
    if (event is ErrorEvent) {
      subscriber.error(event.error, event.stackTrace);
    } else {
      subscriber.add(Disposable.of(event.value));
    }
    return subscriber;
  }
}
