library rx.operators.ref_count;

import '../../observables.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscription.dart';

extension RefCountOperator<T> on ConnectableObservable<T> {
  /// Connects to the source only if there is more than one subscriber.
  Observable<T> refCount() => RefCountObservable<T>(this);
}

class RefCountObservable<T> extends Observable<T> {
  final ConnectableObservable<T> observable;

  Subscription subscription = Subscription.empty();
  int count = 0;

  RefCountObservable(this.observable);

  @override
  Subscription subscribe(Observer<T> observer) {
    if (count == 0) {
      subscription = observable.connect();
    }
    count++;
    return Subscription.composite([
      observable.subscribe(observer),
      Subscription.create(() {
        count--;
        if (count == 0) {
          subscription.unsubscribe();
          subscription = Subscription.empty();
        }
      })
    ]);
  }
}
