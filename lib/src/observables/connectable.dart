import '../../disposables.dart';
import '../core/observable.dart';
import '../disposables/disposable.dart';

abstract class ConnectableObservable<T> extends Observable<T> {
  Disposable connect();
}
