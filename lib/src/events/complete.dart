import '../core/observer.dart';
import 'event.dart';

/// Event of the completion of a sequence of type `T`.
class CompleteEvent<T> extends Event<T> {
  const CompleteEvent();

  @override
  bool get isComplete => true;

  @override
  void observe(Observer<T> observer) => observer.complete();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CompleteEvent;

  @override
  int get hashCode => 34822;

  @override
  String toString() => 'CompleteEvent<$T>()';
}
