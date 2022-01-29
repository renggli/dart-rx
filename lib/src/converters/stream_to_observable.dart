import 'dart:async' show Stream;

import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/action.dart';
import '../disposables/disposable.dart';

extension StreamToObservable<T> on Stream<T> {
  /// Returns an [Observable] that listens to this [Stream].
  Observable<T> toObservable() => StreamObservable<T>(this);
}

class StreamObservable<T> implements Observable<T> {
  StreamObservable(this.stream);

  final Stream<T> stream;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscription = stream.listen(observer.next,
        onError: observer.error, onDone: observer.complete);
    return ActionDisposable(subscription.cancel);
  }
}
