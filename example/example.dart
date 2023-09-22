import 'dart:io';

import 'package:more/collection.dart';
import 'package:rx/constructors.dart' as rx;
import 'package:rx/converters.dart';
import 'package:rx/core.dart';
import 'package:rx/operators.dart';

Observer<T> printObserver<T>(String name) => Observer(
      next: (value) => stdout.writeln('$name.next($value)'),
      error: (error, stackTrace) => stdout.writeln('$name.error($error)'),
      complete: () => stdout.writeln('$name.complete()'),
    );

void main() {
  // concat
  final concat = rx.concat([
    [1, 2].toObservable(),
    rx.just(3)
  ]);
  concat.subscribe(printObserver('concat'));

  // create
  final create = rx.create((emitter) {
    for (var i = 0; i < 3; i++) {
      emitter.next(i);
    }
    emitter.complete();
  });
  create.subscribe(printObserver('create'));

  // defer
  final defer = rx.defer(() => rx.just(42));
  defer.subscribe(printObserver('defer'));

  // empty
  final empty = rx.empty();
  empty.subscribe(printObserver('empty'));

  // future
  final fromFuture = Future.value(42).toObservable();
  fromFuture.subscribe(printObserver('fromFuture'));

  final toFuture = [1, 2, 3].toObservable().toFuture();
  toFuture.then((value) => stdout.writeln('toFuture.then($value)'));

  // iff
  final iff = rx.iff(() => true, rx.just(true), rx.just(false));
  iff.subscribe(printObserver('iff'));

  // just
  final just = rx.just(42);
  just.subscribe(printObserver('just'));

  // merge
  final merge = rx.merge([
    rx.just(1),
    [2, 3].toObservable()
  ]);
  merge.subscribe(printObserver('merge'));

  // never
  final never = rx.never();
  never.subscribe(printObserver('never'));

  // stream
  final fromStream = Stream.fromIterable([1, 2, 3]).toObservable();
  fromStream.subscribe(printObserver('fromStream'));

  final toStream = [1, 2, 3].toObservable().toStream();
  toStream.listen((value) => stdout.writeln('toStream.value($value)'));

  // throwError
  final throwError = rx.throwError(Exception('Hello World'));
  throwError.subscribe(printObserver('throw'));

  // pairwise
  final pairwise = [1, 2, 3, 4].toObservable().pairwise();
  pairwise.subscribe(printObserver('pairwise'));

  // double subscription
  final transformed = IntegerRange(100)
      .toObservable()
      .where((value) => value.isEven)
      .map((value) => '${value * value}')
      .where((value) => value.length < 2);
  transformed.subscribe(printObserver('one'));
  transformed.subscribe(printObserver('two'));

  // subject subscription
  final subject =
      IntegerRange(0, 100, 25).toObservable().publishReplay().refCount();
  subject.subscribe(printObserver('subject1'));
  subject.subscribe(printObserver('subject2'));

  // timer
  final obs = rx.timer(
      delay: const Duration(seconds: 2),
      period: const Duration(milliseconds: 500));
  final subs1 = obs.subscribe(printObserver('first'));
  final subs2 = obs.subscribe(printObserver('second'));
  rx
      .timer(delay: const Duration(seconds: 3))
      .subscribe(Observer(complete: subs1.dispose));
  rx
      .timer(delay: const Duration(seconds: 5))
      .subscribe(Observer(complete: subs2.dispose));

  // zip
  final zip = rx.zip<Object>([
    <Object>[1, 2, 3].toObservable(),
    <Object>['a', 'b'].toObservable(),
  ]);
  zip.subscribe(printObserver('zip'));
}
