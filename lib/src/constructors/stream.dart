library rx.converters.stream;

import 'dart:async' show Stream, StreamController;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

extension FromStreamConstructor<T> on Stream<T> {
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

extension ToStreamConstructor<T> on Observable<T> {
  /// A [Stream] that listens to an [Observable].
  Stream<T> toStream() {
    var subscription = Subscription.empty();
    final controller = StreamController<T>();
    final observer = Observer<T>(
      next: controller.add,
      error: controller.addError,
      complete: controller.close,
    );
    controller.onListen = () {
      if (subscription.isClosed) {
        subscription = subscribe(observer);
      }
    };
    controller.onCancel = subscription.unsubscribe;
    return controller.stream;
  }
}
