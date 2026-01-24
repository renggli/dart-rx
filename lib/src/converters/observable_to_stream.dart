import 'dart:async' show Stream, StreamController;

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/sequential.dart';

extension ObservableToStream<T> on Observable<T> {
  /// Returns a [Stream] that subscribes to and emits the values of this
  /// [Observable].
  ///
  /// For example:
  ///
  /// ```dart
  /// just(1).toStream().listen(print); // prints 1
  /// ```
  Stream<T> toStream() {
    final disposable = SequentialDisposable();
    final controller = StreamController<T>();
    controller.onListen = () {
      disposable.current = subscribe(
        Observer<T>(
          next: controller.add,
          error: controller.addError,
          complete: controller.close,
        ),
      );
    };
    controller.onCancel = disposable.dispose;
    return controller.stream;
  }
}
