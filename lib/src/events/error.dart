import '../core/observer.dart';
import 'event.dart';

/// Event of an error with optional stack trace of a sequence of type `T`.
class ErrorEvent<T> extends Event<T> {
  @override
  final Object error;

  @override
  final StackTrace stackTrace;

  const ErrorEvent(this.error, this.stackTrace);

  @override
  bool get isError => true;

  @override
  void observe(Observer<T> observer) => observer.error(error, stackTrace);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ErrorEvent && error == other.error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'ErrorEvent{error: $error, stackTrace: $stackTrace}';
}
