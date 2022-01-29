import '../disposables/disposable.dart';
import 'observer.dart';

// Mixin to make an object observable.
abstract class Observable<T> {
  /// Subscribes with the provided [observer].
  Disposable subscribe(Observer<T> observer);
}
