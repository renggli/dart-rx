import '../disposables/disposable.dart';
import 'observer.dart';
import 'operator.dart';
import 'subscriber.dart';

abstract class Observable<T> {
  /// Creates a new observable with the provided [operator].
  Observable<R> lift<R>(Operator<T, R> operator) =>
      _OperatorObservable(this, operator);

  /// Subscribes with the provided [observer].
  Disposable subscribe(Observer<T> observer);
}

class _OperatorObservable<T, R> extends Observable<R> {
  final Observable<T> source;
  final Operator<T, R> operator;

  _OperatorObservable(this.source, this.operator);

  @override
  Disposable subscribe(Observer<R> observer) {
    final subscriber = Subscriber<R>(observer);
    subscriber.add(operator(source, subscriber));
    return subscriber;
  }
}
