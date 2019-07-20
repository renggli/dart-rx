library rx.example.example;

import 'package:more/collection.dart';
import 'package:rx/constructors.dart';
import 'package:rx/core.dart';
import 'package:rx/operators.dart';

Observer<T> printObserver<T>(String name) => Observer(
      next: (value) => print('$name.next($value)'),
      error: (error, [stackTrace]) => print('$name.error($error)'),
      complete: () => print('$name.complete()'),
    );

void main() {
  // create
  final createObservable = create((subscriber) {
    for (var i = 0; i < 3; i++) {
      subscriber.next(i);
    }
    subscriber.complete();
  });
  createObservable.subscribe(printObserver('createObservable'));

  // empty
  final emptyObservable = empty();
  emptyObservable.subscribe(printObserver('emptyObservable'));

  // future
  final futureObservable = fromFuture(Future.value(42));
  futureObservable.subscribe(printObserver('futureObservable'));

  // just
  final justObservable = just(42);
  justObservable.subscribe(printObserver('justObservable'));

  // never
  final neverObservable = never();
  neverObservable.subscribe(printObserver('neverObservable'));

  // stream
  final streamObservable = fromStream(Stream.fromIterable([1, 2, 3]));
  streamObservable.subscribe(printObserver('streamObservable'));

  // throw
  final throwObservable = throwError(Exception('Hello World'));
  throwObservable.subscribe(printObserver('throwObservable'));

  // Other:
  final transformed = fromIterable(IntegerRange(0, 100))
      .lift(filter((value) => value.isEven))
      .lift(map((value) => 'Observable{value * value}'))
      .lift(filter((value) => value.length < 3));

  transformed.subscribe(printObserver('one'));
  transformed.subscribe(printObserver('two'));

  final obs = timer(
      delay: const Duration(seconds: 2),
      period: const Duration(milliseconds: 500));
  final subs1 = obs.subscribe(printObserver('first'));
  final subs2 = obs.subscribe(printObserver('second'));

  timer(delay: const Duration(seconds: 3))
      .subscribe(Observer(complete: () => subs1.unsubscribe()));
  timer(delay: const Duration(seconds: 5))
      .subscribe(Observer(complete: () => subs2.unsubscribe()));
}
