library rx.constructors.create;

import 'package:rx/src/core/events.dart';
import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscriber.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/shared/functions.dart';

extension CreateConstructor on Observable {
  /// Creates an observable sequence from a specified subscribe method
  /// implementation.
  static Observable<T> create<T>(
          Map1<Subscriber<T>, dynamic> subscribeFunction) =>
      SubscribeObservable<T>(subscribeFunction);
}

class SubscribeObservable<T> extends Observable<T> {
  final Map1<Subscriber<T>, dynamic> callback;

  SubscribeObservable(this.callback);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscriber = Subscriber<T>(observer);
    final event = Event.map1(callback, subscriber);
    if (event is ErrorEvent) {
      subscriber.error(event.error, event.stackTrace);
    } else {
      subscriber.add(Subscription.of(event.value));
    }
    return subscriber;
  }
}
