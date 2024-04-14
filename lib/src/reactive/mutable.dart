import '../core/observer.dart';
import 'value.dart';

/// A mutable reactive value.
class Mutable<T> extends Value<T> {
  Mutable(this._value);

  T _value;

  @override
  T get value {
    if (active != null) subscribe(active as Observer<T>);
    return _value;
  }

  /// Update the currently held value.
  set value(T value) {
    if (value == _value) return;
    update(_value = value);
  }
}
