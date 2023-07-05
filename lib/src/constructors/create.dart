import 'package:more/functional.dart';

import '../../disposables.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';

/// Creates an [Observable] that uses the provided `callback` to emit elements
/// to the provided [Observer] on each subscribe.
/// The `callback` may return a [Disposable] or a [Callback0] to be called when
/// the subscription is disposed.
Observable<T> create<T>(
        Map1<Subscriber<T>, dynamic /* Disposable|Callback0|null */ >
            callback) =>
    CreateObservable<T>(callback);

class CreateObservable<T> implements Observable<T> {
  CreateObservable(this.callback);

  final Map1<Subscriber<T>, dynamic> callback;

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = Subscriber<T>(observer);
    try {
      final onDispose = callback(subscriber);
      if (onDispose is Disposable) {
        subscriber.add(onDispose);
      } else if (onDispose is Callback0) {
        subscriber.add(ActionDisposable(onDispose));
      } else if (onDispose != null) {
        subscriber.error(
            Exception('Unknown return type: ${onDispose.runtimeType}'),
            StackTrace.current);
      }
    } catch (error, stackTrace) {
      subscriber.error(error, stackTrace);
    }
    return subscriber;
  }
}
