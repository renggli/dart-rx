import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../shared/functions.dart';

/// Creates an [Observable] that uses the provided `callback` to emit elements
/// to the provided [Observer] on each subscribe.
Observable<T> create<T>(Callback1<Subscriber<T>> callback) =>
    CreateObservable<T>(callback);

class CreateObservable<T> extends Observable<T> {
  final Callback1<Subscriber<T>> callback;

  CreateObservable(this.callback);

  @override
  Disposable subscribe(Observer<T> observer) {
    final subscriber = Subscriber<T>(observer);
    try {
      callback(subscriber);
    } catch (error, stackTrace) {
      subscriber.error(error, stackTrace);
    }
    return subscriber;
  }
}
