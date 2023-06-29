import '../core/observer.dart';
import '../disposables/disposable.dart';
import 'subject.dart';

/// A [Subject] that emits its initial or last seen value to its subscribers.
class BehaviorSubject<T> extends Subject<T> {
  BehaviorSubject(this._value);

  T _value;

  /// Returns the current value.
  T get value => _value;

  @override
  void next(T value) => super.next(_value = value);

  @override
  Disposable subscribeToActive(Observer<T> observer) {
    observer.next(_value);
    return super.subscribeToActive(observer);
  }

  @override
  Disposable subscribeToComplete(Observer<T> observer) {
    observer.next(_value);
    return super.subscribeToComplete(observer);
  }
}
