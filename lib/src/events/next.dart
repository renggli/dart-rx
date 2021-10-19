import '../core/observer.dart';
import 'event.dart';

/// Event with value of type `T`.
class NextEvent<T> extends Event<T> {
  @override
  final T value;

  const NextEvent(this.value);

  @override
  bool get isNext => true;

  @override
  void observe(Observer<T> observer) => observer.next(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NextEvent && value == other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NextEvent<$T>(value: $value)';
}
