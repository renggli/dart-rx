library rx.example.example;

import 'package:more/collection.dart';
import 'package:rx/rx.dart';

Observer<T> printObserver<T>(String name) => Observer(
      next: (value) => print('$name.next($value)'),
      error: (error, [stackTrace]) => print('$name.error($error)'),
      complete: () => print('$name.complete()'),
    );

void main() {
  // create
  final create = Observable.create((subscriber) {
    for (var i = 0; i < 3; i++) {
      subscriber.next(i);
    }
    subscriber.complete();
  });
  create.subscribe(printObserver('create'));

  // empty
  final empty = Observable.empty();
  empty.subscribe(printObserver('empty'));

  // future
  final fromFuture = Future.value(42).toObservable();
  fromFuture.subscribe(printObserver('fromFuture'));

  final toFuture = [1, 2, 3].toObservable().toFuture();
  toFuture.then((value) => print('toFuture.then($value)'));

  // just
  final just = Observable.just(42);
  just.subscribe(printObserver('just'));

  // never
  final never = Observable.never();
  never.subscribe(printObserver('never'));

  // stream
  final fromStream = Stream.fromIterable([1, 2, 3]).toObservable();
  fromStream.subscribe(printObserver('fromStream'));

  final toStream = [1, 2, 3].toObservable().toStream();
  toStream.listen((value) => print('toStream.value($value)'));

  // throw
  final throwError = Observable.throwError(Exception('Hello World'));
  throwError.subscribe(printObserver('throw'));

  // double subscription
  final transformed = IntegerRange(0, 100)
      .toObservable()
      .where((value) => value.isEven)
      .map((value) => '{value * value}')
      .map((value) => value.length < 3);
  transformed.subscribe(printObserver('one'));
  transformed.subscribe(printObserver('two'));

  // subject subscription
  final subject =
      IntegerRange(0, 100, 25).toObservable().publishReplay().refCount();
  subject.subscribe(printObserver('subject1'));
  subject.subscribe(printObserver('subject2'));

  // timer
  final obs = Observable.timer(
      delay: const Duration(seconds: 2),
      period: const Duration(milliseconds: 500));
  final subs1 = obs.subscribe(printObserver('first'));
  final subs2 = obs.subscribe(printObserver('second'));
  Observable.timer(delay: const Duration(seconds: 3))
      .subscribe(Observer(complete: () => subs1.unsubscribe()));
  Observable.timer(delay: const Duration(seconds: 5))
      .subscribe(Observer(complete: () => subs2.unsubscribe()));
}
