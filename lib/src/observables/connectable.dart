import '../../disposables.dart';
import '../core/observable.dart';
import '../disposables/disposable.dart';

mixin ConnectableObservable<T> implements Observable<T> {
  Disposable connect();
}
