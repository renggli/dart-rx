import 'package:rx/constructors.dart';
import 'package:rx/converters.dart';
import 'package:rx/core.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  final scheduler = TestScheduler();
  setUp(scheduler.setUp);
  tearDown(scheduler.tearDown);

  group('Iterable.toObservable', () {
    test('completes on empty collection', () {
      final actual = <String>[].toObservable();
      expect(actual, scheduler.isObservable<String>('|'));
    });
    test('emits all the values', () {
      final actual = ['a', 'b', 'c'].toObservable();
      expect(actual, scheduler.isObservable<String>('(abc|)'));
    });
  });
  group('Future.toObservable', () {
    test('completes with value', () {
      final actual = Future.value('a').toObservable();
      actual.subscribe(Observer(
        next: (value) => expect(value, 'a'),
        error: (error, stackTrace) => fail('No error expected'),
      ));
    });
    test('completes with error', () {
      final actual = Future<String>.error('Error').toObservable();
      actual.subscribe(Observer(
        next: (value) => fail('No value expected'),
        error: (error, stackTrace) => expect(error, 'Error'),
      ));
    });
  });
  group('Stream.toObservable', () {
    test('completes immediately', () {
      final actual = const Stream<String>.empty().toObservable();
      final observed = <String>[];
      actual.subscribe(Observer(
        next: (value) => fail('No value expected'),
        error: (error, stackTrace) => fail('No error expected'),
        complete: () => expect(observed, <String>[]),
      ));
    });
    test('completes with values', () {
      final actual = Stream.fromIterable(['a', 'b', 'c']).toObservable();
      final observed = <String>[];
      actual.subscribe(Observer(
        next: observed.add,
        error: (error, stackTrace) => fail('No error expected'),
        complete: () => expect(observed, ['a', 'b', 'c']),
      ));
    });
    test('completes with error', () {
      final actual =
          Stream.fromFuture(Future<String>.error('Error')).toObservable();
      actual.subscribe(Observer(
        next: (value) => fail('No value expected'),
        error: (error, stackTrace) => expect(error, 'Error'),
        complete: () => fail('No completion expected'),
      ));
    });
    test('subscription', () {
      final actual = Stream.fromIterable([1, 2, 3]).toObservable();
      final subscription = actual.subscribe(Observer(
        next: (value) => fail('No value expected'),
        error: (error, stackTrace) => expect(error, 'Error'),
        complete: () => fail('No completion expected'),
      ));
      expect(subscription.isDisposed, isFalse);
      subscription.dispose();
      expect(subscription.isDisposed, isTrue);
    });
  });
  group('Observable.toFuture', () {
    test('empty observable', () {
      final actual = empty().toFuture();
      expect(actual, throwsTooFewError);
    });
    test('single value', () {
      final actual = just(42).toFuture();
      expect(actual, completion(42));
    });
    test('multiple values', () {
      final actual = [1, 2, 3]
          .toObservable(scheduler: const ImmediateScheduler())
          .toFuture();
      expect(actual, completion(1));
    });
    test('immediate error', () {
      final actual = throwError(TooManyError()).toFuture();
      expect(actual, throwsTooManyError);
    });
  });
  group('Observable.toStream', () {
    test('empty observable', () {
      final actual = empty().toStream();
      expect(actual, emitsDone);
    });
    test('single value', () {
      final actual = just(42).toStream();
      expect(actual, emitsInOrder(<int>[42]));
    });
    test('multiple values', () {
      final actual = [1, 2, 3]
          .toObservable(scheduler: const ImmediateScheduler())
          .toStream();
      expect(actual, emitsInOrder(<int>[1, 2, 3]));
    });
    test('immediate error', () {
      final actual = throwError(TooManyError()).toStream();
      expect(actual, emitsError(const TypeMatcher<TooManyError>()));
    });
  });
}
