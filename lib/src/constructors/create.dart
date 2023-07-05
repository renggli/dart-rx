import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/action.dart';
import '../disposables/composite.dart';
import '../disposables/disposable.dart';

/// Creates an [Observable] that uses the provided `callback` to emit elements
/// to the provided [Observer] on each subscribe.
/// Optionally pass an [onDispose] callback that will be called when the
/// subscription is cancelled.
Observable<T> create<T>(Callback1<Subscriber<T>> callback,
        {Callback0? onDispose}) =>
    CreateObservable<T>(callback, onDispose);

class CreateObservable<T> implements Observable<T> {
  CreateObservable(this.callback, this.dispose);

  final Callback1<Subscriber<T>> callback;
  final Callback0? dispose;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = Subscriber<T>(observer);
    try {
      callback(subscriber);
    } catch (error, stackTrace) {
      subscriber.error(error, stackTrace);
    }
    return dispose == null
        ? subscriber
        : CompositeDisposable([subscriber, ActionDisposable(dispose!)]);
  }
}
