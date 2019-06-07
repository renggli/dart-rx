library rx.test.operators_test;

import 'package:rx/operators.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart';

void main() {
  final scheduler = TestScheduler();
  scheduler.install();

  group('filter', () {
    test('first value filterd', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.lift(filter((value) => value != 'a'));
      expect(actual, scheduler.isObservable('-----b--|'));
    });
    test('second value filtered', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.lift(filter((value) => value != 'b'));
      expect(actual, scheduler.isObservable('--a-----|'));
    });
    test('second value filtered and error', () {
      final input = scheduler.cold('--a--b--#');
      final actual = input.lift(filter((value) => value != 'b'));
      expect(actual, scheduler.isObservable('--a-----#'));
    });
  });
  group('last', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(last());
      expect(
          actual,
          scheduler.isObservable('--#',
              error: 'Sequence contains no elements'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(last());
      expect(actual, scheduler.isObservable('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(last());
      expect(actual, scheduler.isObservable('-----------(c|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(last());
      expect(
          actual,
          scheduler.isObservable('-----------#'));
    });
  });
  group('lastOrDefault', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(lastOrDefault('x'));
      expect(actual, scheduler.isObservable('--(x|)'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(lastOrDefault('x'));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(lastOrDefault('x'));
      expect(actual, scheduler.isObservable('-----------(c|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(lastOrDefault('x'));
      expect(actual, scheduler.isObservable('-----------#'));
    });
  });
  group('map', () {
    test('single value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(map((value) => '$value!'));
      expect(actual, scheduler.isObservable('--a--|', values: {'a': 'a!'}));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(map((value) => '$value!'));
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': 'a!', 'b': 'b!', 'c': 'c!'}));
    });
    test('single value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(map((value) => '$value!'));
      expect(actual, scheduler.isObservable('--a--#', values: {'a': 'a!'}));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(map((value) => '$value!'));
      expect(
          actual,
          scheduler.isObservable('--a--b--c--#',
              values: {'a': 'a!', 'b': 'b!', 'c': 'c!'}));
    });
  });
  group('mapTo', () {
    test('single value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--|'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--x--x--|'));
    });
    test('single value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--#'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--x--x--#'));
    });
  });
}
