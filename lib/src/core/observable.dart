library rx.core.observable;

import 'observer.dart';
import 'operator.dart';
import 'subscriber.dart';
import 'subscription.dart';

abstract class Observable<T> {
  Observable<S> lift<S>(Operator<T, S> operator) =>
      _OperatorObservable(this, operator);

  Subscription subscribe(Observer<T> observer);

  /// Pipe two [Operator], identical to multiple [Observable.lift] calls.
  Observable<T2> pipe2<T1, T2>(
    Operator<T, T1> operator1,
    Operator<T1, T2> operator2,
  ) =>
      lift(operator1).lift(operator2);

  /// Pipe three [Operator], identical to multiple [Observable.lift] calls.
  Observable<T3> pipe3<T1, T2, T3>(
    Operator<T, T1> operator1,
    Operator<T1, T2> operator2,
    Operator<T2, T3> operator3,
  ) =>
      lift(operator1).lift(operator2).lift(operator3);

  /// Pipe four [Operator], identical to multiple [Observable.lift] calls.
  Observable<T4> pipe4<T1, T2, T3, T4>(
    Operator<T, T1> operator1,
    Operator<T1, T2> operator2,
    Operator<T2, T3> operator3,
    Operator<T3, T4> operator4,
  ) =>
      lift(operator1).lift(operator2).lift(operator3).lift(operator4);

  /// Pipe five [Operator], identical to multiple [Observable.lift] calls.
  Observable<T5> pipe5<T1, T2, T3, T4, T5>(
          Operator<T, T1> operator1,
          Operator<T1, T2> operator2,
          Operator<T2, T3> operator3,
          Operator<T3, T4> operator4,
          Operator<T4, T5> operator5) =>
      lift(operator1)
          .lift(operator2)
          .lift(operator3)
          .lift(operator4)
          .lift(operator5);

  /// Pipe six [Operator], identical to multiple [Observable.lift] calls.
  Observable<T6> pipe6<T1, T2, T3, T4, T5, T6>(
          Operator<T, T1> operator1,
          Operator<T1, T2> operator2,
          Operator<T2, T3> operator3,
          Operator<T3, T4> operator4,
          Operator<T4, T5> operator5,
          Operator<T5, T6> operator6) =>
      lift(operator1)
          .lift(operator2)
          .lift(operator3)
          .lift(operator4)
          .lift(operator5)
          .lift(operator6);

  /// Pipe seven [Operator], identical to multiple [Observable.lift] calls.
  Observable<T7> pipe7<T1, T2, T3, T4, T5, T6, T7>(
          Operator<T, T1> operator1,
          Operator<T1, T2> operator2,
          Operator<T2, T3> operator3,
          Operator<T3, T4> operator4,
          Operator<T4, T5> operator5,
          Operator<T5, T6> operator6,
          Operator<T6, T7> operator7) =>
      lift(operator1)
          .lift(operator2)
          .lift(operator3)
          .lift(operator4)
          .lift(operator5)
          .lift(operator6)
          .lift(operator7);

  /// Pipe eight [Operator], identical to multiple [Observable.lift] calls.
  Observable<T8> pipe8<T1, T2, T3, T4, T5, T6, T7, T8>(
          Operator<T, T1> operator1,
          Operator<T1, T2> operator2,
          Operator<T2, T3> operator3,
          Operator<T3, T4> operator4,
          Operator<T4, T5> operator5,
          Operator<T5, T6> operator6,
          Operator<T6, T7> operator7,
          Operator<T7, T8> operator8) =>
      lift(operator1)
          .lift(operator2)
          .lift(operator3)
          .lift(operator4)
          .lift(operator5)
          .lift(operator6)
          .lift(operator7)
          .lift(operator8);

  /// Pipe nine [Operator], identical to multiple [Observable.lift] calls.
  Observable<T9> pipe9<T1, T2, T3, T4, T5, T6, T7, T8, T9>(
          Operator<T, T1> operator1,
          Operator<T1, T2> operator2,
          Operator<T2, T3> operator3,
          Operator<T3, T4> operator4,
          Operator<T4, T5> operator5,
          Operator<T5, T6> operator6,
          Operator<T6, T7> operator7,
          Operator<T7, T8> operator8,
          Operator<T8, T9> operator9) =>
      lift(operator1)
          .lift(operator2)
          .lift(operator3)
          .lift(operator4)
          .lift(operator5)
          .lift(operator6)
          .lift(operator7)
          .lift(operator8)
          .lift(operator9);
}

class _OperatorObservable<T, R> extends Observable<R> {
  final Observable<T> source;
  final Operator<T, R> operator;

  _OperatorObservable(this.source, this.operator);

  @override
  Subscription subscribe(Observer<R> observer) {
    final subscriber = Subscriber<R>(observer);
    subscriber.add(operator.call(subscriber, source));
    return subscriber;
  }
}
