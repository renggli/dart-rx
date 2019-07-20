library rx.example.example;

import 'package:more/collection.dart';
import 'package:rx/rx.dart' as rx;
import 'package:rx/operators.dart' as ops;

rx.Observer<T> printObserver<T>(String name) => rx.Observer(
      next: (value) => print('$name.next($value)'),
      error: (error, [stackTrace]) => print('$name.error($error)'),
      complete: () => print('$name.complete()'),
    );

void main() {
  // create
  final create = rx.create((subscriber) {
    for (var i = 0; i < 3; i++) {
      subscriber.next(i);
    }
    subscriber.complete();
  });
  create.subscribe(printObserver('create'));

  // empty
  final empty = rx.empty();
  empty.subscribe(printObserver('empty'));

  // future
  final future = rx.fromFuture(Future.value(42));
  future.subscribe(printObserver('future'));

  // just
  final just = rx.just(42);
  just.subscribe(printObserver('just'));

  // never
  final never = rx.never();
  never.subscribe(printObserver('never'));

  // stream
  final stream = rx.fromStream(Stream.fromIterable([1, 2, 3]));
  stream.subscribe(printObserver('stream'));

  // throw
  final throwError = rx.throwError(Exception('Hello World'));
  throwError.subscribe(printObserver('throw'));

  // Other:
  final transformed = rx
      .fromIterable(IntegerRange(0, 100))
      .lift(ops.filter((value) => value.isEven))
      .lift(ops.map((value) => '{value * value}'))
      .lift(ops.filter((value) => value.length < 3));

  transformed.subscribe(printObserver('one'));
  transformed.subscribe(printObserver('two'));

  final obs = rx.timer(
      delay: const Duration(seconds: 2),
      period: const Duration(milliseconds: 500));
  final subs1 = obs.subscribe(printObserver('first'));
  final subs2 = obs.subscribe(printObserver('second'));

  rx
      .timer(delay: const Duration(seconds: 3))
      .subscribe(rx.Observer(complete: () => subs1.unsubscribe()));
  rx
      .timer(delay: const Duration(seconds: 5))
      .subscribe(rx.Observer(complete: () => subs2.unsubscribe()));
}
