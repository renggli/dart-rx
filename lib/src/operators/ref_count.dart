library rx.operators.ref_count;

import '../../observables.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/disposable.dart';

extension RefCountOperator<T> on ConnectableObservable<T> {
  /// Connects to the source only if there is more than one subscriber.
  Observable<T> refCount() => RefCountObservable<T>(this);
}

class RefCountObservable<T> extends Observable<T> {
  final ConnectableObservable<T> observable;

  Disposable subscription = Disposable.empty();
  int count = 0;

  RefCountObservable(this.observable);

  @override
  Disposable subscribe(Observer<T> observer) {
    if (count == 0) {
      subscription = observable.connect();
    }
    count++;
    return Disposable.composite([
      observable.subscribe(observer),
      Disposable.create(() {
        count--;
        if (count == 0) {
          subscription.dispose();
          subscription = Disposable.empty();
        }
      })
    ]);
  }
}
