library rx.converters.stream_to_observable;

import 'dart:async' show Stream;

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/action.dart';
import '../disposables/disposable.dart';

extension StreamToObservable<T> on Stream<T> {
  /// Returns an [Observable] that listens to this [Stream].
  Observable<T> toObservable() => StreamObservable<T>(this);
}

class StreamObservable<T> with Observable<T> {
  final Stream<T> stream;

  StreamObservable(this.stream);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscription = stream.listen(observer.next,
        onError: observer.error, onDone: observer.complete);
    return ActionDisposable(subscription.cancel);
  }
}
