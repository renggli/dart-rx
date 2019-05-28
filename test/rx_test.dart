library rx.test.core;

import 'package:rx/constructors.dart';
import 'package:rx/core.dart';

Observer<T> printObserver<T>(String name) => PluggableObserver(
      (value) => print('$name.next($value)'),
      (error, [stackTrace]) => print('$name.error($error)'),
      () => print('$name.complete()'),
    );

void main() {
//  final observable = Observable((subscriber) {
//    for (var i = 0; i < 1000; i++) {
//      subscriber.next(i);
//    }
//    subscriber.complete();
//  });
//  final transformed = observable
//      .lift(filter((value) => value.isEven))
//      .lift(map((value) => '${value * value}'))
//      .lift(filter((value) => value.length < 3))
//      .lift(take(3));

  final obs = timer(Duration(seconds: 2), Duration(milliseconds: 500));
  final subs1 = obs.subscribe(printObserver('1'));
  final subs2 = obs.subscribe(printObserver('2'));

  timer(Duration(seconds: 3))
      .subscribe(Observer(complete: () => subs1.unsubscribe()));
  timer(Duration(seconds: 5))
      .subscribe(Observer(complete: () => subs2.unsubscribe()));
}
