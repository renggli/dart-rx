import 'package:checks/checks.dart';
import 'package:rx/constructors.dart';
import 'package:rx/converters.dart';
import 'package:rx/core.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/testing.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

void main() {
  final scheduler = TestScheduler();
  setUp(scheduler.setUp);
  tearDown(scheduler.tearDown);

  group('Iterable.toObservable', () {
    test('completes on empty collection', () {
      final actual = <String>[].toObservable();
      check(actual).matches(scheduler.isObservable<String>('|'));
    });

    test('emits all the values', () {
      final actual = ['a', 'b', 'c'].toObservable();
      check(actual).matches(scheduler.isObservable<String>('(abc|)'));
    });
  });

  group('Future.toObservable', () {
    test('completes with value', () {
      final actual = Future.value('a').toObservable();
      actual.subscribe(
        Observer(
          next: (value) => check(value).equals('a'),
          error: (error, stackTrace) => fail('No error expected'),
        ),
      );
    });

    test('completes with error', () {
      final actual = Future<String>.error('Error').toObservable();
      actual.subscribe(
        Observer(
          next: (value) => fail('No value expected'),
          error: (error, stackTrace) => check(error).equals('Error'),
        ),
      );
    });
  });

  group('Stream.toObservable', () {
    test('completes immediately', () {
      final actual = const Stream<String>.empty().toObservable();
      final observed = <String>[];
      actual.subscribe(
        Observer(
          next: (value) => fail('No value expected'),
          error: (error, stackTrace) => fail('No error expected'),
          complete: () => check(observed).isEmpty(),
        ),
      );
    });

    test('completes with values', () {
      final actual = Stream.fromIterable(['a', 'b', 'c']).toObservable();
      final observed = <String>[];
      actual.subscribe(
        Observer(
          next: observed.add,
          error: (error, stackTrace) => fail('No error expected'),
          complete: () => check(observed).deepEquals(['a', 'b', 'c']),
        ),
      );
    });

    test('completes with error', () {
      final actual = Stream.fromFuture(Future<String>.error('Error'))
          .toObservable();
      actual.subscribe(
        Observer(
          next: (value) => fail('No value expected'),
          error: (error, stackTrace) => check(error).equals('Error'),
          complete: () => fail('No completion expected'),
        ),
      );
    });

    test('subscription', () {
      final actual = Stream.fromIterable([1, 2, 3]).toObservable();
      final subscription = actual.subscribe(
        Observer(
          next: (value) => fail('No value expected'),
          error: (error, stackTrace) => check(error).equals('Error'),
          complete: () => fail('No completion expected'),
        ),
      );
      check(subscription).isDisposed.isFalse();
      subscription.dispose();
      check(subscription).isDisposed.isTrue();
    });
  });

  group('Observable.toFuture', () {
    test('empty observable', () async {
      final actual = empty().toFuture();
      await check(actual).throws<TooFewError>();
    });

    test('single value', () async {
      final actual = just(42).toFuture();
      await check(actual).completes((it) => it.equals(42));
    });

    test('multiple values', () async {
      final actual = [
        1,
        2,
        3,
      ].toObservable(scheduler: const ImmediateScheduler()).toFuture();
      await check(actual).completes((it) => it.equals(1));
    });

    test('immediate error', () async {
      final actual = throwError(TooManyError()).toFuture();
      await check(actual).throws<TooManyError>();
    });
  });

  group('Observable.toStream', () {
    test('empty observable', () async {
      final actual = empty().toStream();
      await check(actual).withQueue.isDone();
    });

    test('single value', () async {
      final actual = just(42).toStream();
      check(await actual.toList()).deepEquals([42]);
    });

    test('multiple values', () async {
      final actual = [
        1,
        2,
        3,
      ].toObservable(scheduler: const ImmediateScheduler()).toStream();
      check(await actual.toList()).deepEquals([1, 2, 3]);
    });

    test('immediate error', () async {
      final actual = throwError(TooManyError()).toStream();
      await check(actual).withQueue.emitsError<TooManyError>();
    });
  });
}
