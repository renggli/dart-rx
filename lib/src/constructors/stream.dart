library rx.constructors.stream;

import 'dart:async' show Stream, StreamController, StreamSubscription;

import 'package:rx/src/core/observable.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subscription.dart';
import 'package:rx/src/observers/base.dart';

/// An [Observable] that listens to a [Stream].
Observable<T> fromStream<T>(Stream<T> stream) => _StreamObservable<T>(stream);

class _StreamObservable<T> with Observable<T> {
  final Stream<T> stream;

  const _StreamObservable(this.stream);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscription = stream.listen(observer.next,
        onError: observer.error, onDone: observer.complete);
    return _StreamSubscription(subscription);
  }
}

class _StreamSubscription extends Subscription {
  StreamSubscription _subscription;

  _StreamSubscription(this._subscription);

  @override
  bool get isClosed => _subscription == null;

  @override
  void unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}

/// A [Stream] that listens to an [Observable].
Stream<T> toStream<T>(Observable<T> observable) {
  var subscription = Subscription.empty();
  final controller = StreamController<T>();
  final observer = BaseObserver<T>(
    (value) => controller.add(value),
    (error, [stackTrace]) => controller.addError(error, stackTrace),
    () => controller.close(),
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
