library rx.test.core;

import 'package:more/collection.dart' show IntegerRange;
import 'package:rx/constructors.dart';
import 'package:rx/core.dart';
import 'package:rx/operators.dart';

Observer<T> printObserver<T>(String name) => AnonymousObserver(
      (value) => print('$name.next($value)'),
      (error, [stackTrace]) => print('$name.error($error)'),
      () => print('$name.complete()'),
    );

void main() {
  final observable = Observable((subscriber) {
    for (var i = 0; i < 5; i++) {
      subscriber.next(i);
    }
    subscriber.complete();
  });
  observable.subscribe(printObserver('1to5'));

  final transformed = fromIterable(IntegerRange(0, 100))
      .lift(filter((value) => value.isEven))
      .lift(map((value) => '${value * value}'))
      .lift(filter((value) => value.length < 3));

  transformed.subscribe(printObserver('One'));
  transformed.subscribe(printObserver('Two'));

  final obs = timer(
      delay: Duration(seconds: 2),
      period: Duration(milliseconds: 500));
  final subs1 = obs.subscribe(printObserver('1'));
  final subs2 = obs.subscribe(printObserver('2'));

  timer(delay: Duration(seconds: 3))
      .subscribe(Observer(complete: () => subs1.unsubscribe()));
  timer(delay: Duration(seconds: 5))
      .subscribe(Observer(complete: () => subs2.unsubscribe()));
}
