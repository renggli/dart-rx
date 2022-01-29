import '../../observables.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../disposables/action.dart';
import '../disposables/composite.dart';
import '../disposables/disposable.dart';
import '../disposables/disposed.dart';

extension RefCountOperator<T> on ConnectableObservable<T> {
  /// Connects to the source only if there is more than one subscriber.
  Observable<T> refCount() => RefCountObservable<T>(this);
}

class RefCountObservable<T> implements Observable<T> {
  RefCountObservable(this.observable);

  final ConnectableObservable<T> observable;

  Disposable subscription = const DisposedDisposable();
  int count = 0;

  @override
  Disposable subscribe(Observer<T> observer) {
    if (count == 0) {
      subscription = observable.connect();
    }
    count++;
    return CompositeDisposable([
      observable.subscribe(observer),
      ActionDisposable(() {
        count--;
        if (count == 0) {
          subscription.dispose();
          subscription = const DisposedDisposable();
        }
      })
    ]);
  }
}
