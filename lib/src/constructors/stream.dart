library rx.constructors.stream;

import 'dart:async' show Stream, StreamController;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/subscriptions/stream.dart';

/// An [Observable] that listens to a [Stream].
Observable<T> fromStream<T>(Stream<T> stream) => _StreamObservable<T>(stream);

class _StreamObservable<T> with Observable<T> {
  final Stream<T> stream;

  const _StreamObservable(this.stream);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscription = stream.listen(observer.next,
        onError: observer.error, onDone: observer.complete);
    return StreamSubscription(subscription);
  }
}

/// A [Stream] that listens to an [Observable].
Stream<T> toStream<T>(Observable<T> observable) {
  var subscription = Subscription.empty();
  final controller = StreamController<T>();
  final observer = Observer<T>(
    next: (value) => controller.add(value),
    error: (error, [stackTrace]) => controller.addError(error, stackTrace),
    complete: () => controller.close(),
  );
  controller.onListen = () {
    if (subscription.isClosed) {
      subscription = observable.subscribe(observer);
    }
  };
  controller.onCancel = () {
    subscription.unsubscribe();
  };
  return controller.stream;
}
