library rx.subjects.behavior;

import '../core/observer.dart';
import '../core/subject.dart';
import '../core/subscription.dart';

/// A [Subject] that emits its initial or last seen value to its subscribers.
class BehaviorSubject<T> extends Subject<T> {
  T _value;

  BehaviorSubject(this._value);

  @override
  void next(T value) => super.next(_value = value);

  @override
  Subscription subscribeToActive(Observer observer) {
    observer.next(_value);
    return super.subscribeToActive(observer);
  }

  @override
  Subscription subscribeToComplete(Observer observer) {
    observer.next(_value);
    return super.subscribeToComplete(observer);
  }
}
