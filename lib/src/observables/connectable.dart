import '../../disposables.dart';
import '../core/observable.dart';
import '../disposables/disposable.dart';

mixin ConnectableObservable<T> implements Observable<T> {
  /// Returns `true` if the observable is connected.
  bool get isConnected;

  /// Connects the observable.
  Disposable connect();
}
