library rx.converters.stream_to_observable;

import 'dart:async' show Stream;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

extension StreamToObservable<T> on Stream<T> {
  /// An [Observable] that listens to a [Stream].
  Observable<T> toObservable() => StreamObservable<T>(this);
}

class StreamObservable<T> with Observable<T> {
  final Stream<T> stream;

  StreamObservable(this.stream);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscription = stream.listen(observer.next,
        onError: observer.error, onDone: observer.complete);
    return Subscription.create(subscription.cancel);
  }
}
