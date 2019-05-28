library rx.constructors.stream;

import 'dart:async';

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

/// An [Observable] that emits the values of a [Stream].
Observable<T> fromStream<T>(Stream<T> stream) => _StreamObservable<T>(stream);

class _StreamObservable<T> with Observable<T> {
  final Stream<T> stream;

  _StreamObservable(this.stream);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscription = stream.listen(observer.next,
        onError: observer.error, onDone: observer.complete);
    return StreamSubscription(subscription);
  }
}
