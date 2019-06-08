library rx.subjects.behavior;

import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subject.dart';
import 'package:rx/src/core/subscription.dart';

/// A variant of Subject that requires an initial value and emits its current
/// value whenever it is subscribed to.
class BehaviorSubject<T> extends Subject<T> {
  T _value;

  BehaviorSubject(this._value);

  @override
  void next(T value) => super.next(_value = value);

  @override
  Subscription subscribe(Observer<T> observer) {
    final subscription = super.subscribe(observer);
    if (!subscription.isClosed) {
      observer.next(_value);
    }
    return subscription;
  }
}
