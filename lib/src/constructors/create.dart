import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';

/// Creates an [Observable] that uses the provided `callback` to emit elements
/// to the provided [Subscriber] on each subscribe.
///
/// On each subscription the `callback` is run and a [Disposable] is returned.
/// The `callback` can synchronously or asynchronously generate events on the
/// passed-in subscriber, as well as register dispose actions by using
/// [Subscriber.add].
///
/// For example:
///
///    final observable = create<String>((subscriber) {
///      subscriber.next('a');
///      /* ... */
///      subscriber.add(ActionDisposable(() => /* free expensive resource */));
///    });
///
Observable<T> create<T>(Callback1<Subscriber<T>> callback) =>
    CreateObservable<T>(callback);

class CreateObservable<T> implements Observable<T> {
  CreateObservable(this.callback);

  final Callback1<Subscriber<T>> callback;

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
