library rx.converters.observable_to_stream;

import 'dart:async' show Stream, StreamController;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';

extension ObservableToStream<T> on Observable<T> {
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
