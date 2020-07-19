library rx.core.subscriber;

import 'package:meta/meta.dart';

import '../disposables/composite.dart';
import 'observer.dart';

class Subscriber<T> extends CompositeDisposable with Observer<T> {
  @protected
  final Observer destination;

  Subscriber(this.destination) : super();

  /// Receives the next value.
  @override
  void next(T value) {
    if (isDisposed) {
      return;
    }
    onNext(value);
  }

  /// Handles the next value.
  @protected
  void onNext(T value) => doNext(value);

  /// Passes the next value to the destination.
  @protected
  void doNext(Object value) => destination.next(value);

  /// Receives the error.
  @override
  void error(Object error, [StackTrace stackTrace]) {
    if (isDisposed) {
      return;
    }
    onError(error, stackTrace);
  }

  /// Handles the error.
  @protected
  void onError(Object error, [StackTrace stackTrace]) =>
      doError(error, stackTrace);

  /// Passes the error to the destination.
  @protected
  void doError(Object error, [StackTrace stackTrace]) {
    destination.error(error, stackTrace);
    dispose();
  }

  /// Receives the completion.
  @override
  void complete() {
    if (isDisposed) {
      return;
    }
    onComplete();
  }

  /// Handles the completion.
  @protected
  void onComplete() => doComplete();

  /// Passes the completion to the destination.
  @protected
  void doComplete() {
    destination.complete();
    dispose();
  }
}
