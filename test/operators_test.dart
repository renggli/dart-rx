library rx.test.operators_test;

import 'package:rx/operators.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart' hide isEmpty;

const Map<String, bool> boolMap = {'t': true, 'f': false};

void main() {
  final scheduler = TestScheduler();
  scheduler.install();

  group('catchError', () {});
  group('dematerialize', () {});
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
  group('finalize', () {});
  group('first', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(first());
      expect(
          actual,
          scheduler.isObservable('--#',
              error: 'Sequence contains no elements'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(first());
      expect(actual, scheduler.isObservable('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(first());
      expect(actual, scheduler.isObservable('--(a|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(first());
      expect(actual, scheduler.isObservable('--(a|)'));
    });
  });
  group('firstOrDefault', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(firstOrDefault('x'));
      expect(actual, scheduler.isObservable('--(x|)'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(firstOrDefault('x'));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(firstOrDefault('x'));
      expect(actual, scheduler.isObservable('--(a|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(firstOrDefault('x'));
      expect(actual, scheduler.isObservable('--(a|)'));
    });
  });
  group('isEmpty', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(isEmpty());
      expect(actual, scheduler.isObservable('--(t|)', values: boolMap));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(isEmpty());
      expect(actual, scheduler.isObservable('--#', values: boolMap));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(isEmpty());
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(isEmpty());
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(isEmpty());
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(isEmpty());
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
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
      expect(actual, scheduler.isObservable('-----------#'));
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
    test('single value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(map((value) => '$value!'));
      expect(actual, scheduler.isObservable('--a--#', values: {'a': 'a!'}));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(map((value) => '$value!'));
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': 'a!', 'b': 'b!', 'c': 'c!'}));
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
    test('single value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--x--x--|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--x--x--#'));
    });
  });
  group('materialize', () {});
  group('skip', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(skip(2));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(skip(2));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(skip(2));
      expect(actual, scheduler.isObservable('-----|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(skip(2));
      expect(actual, scheduler.isObservable('-----#'));
    });
    test('two values and completion', () {
      final input = scheduler.cold('--a---b----|');
      final actual = input.lift(skip(2));
      expect(actual, scheduler.isObservable('-----------|'));
    });
    test('two values and error', () {
      final input = scheduler.cold('--a---b----#');
      final actual = input.lift(skip(2));
      expect(actual, scheduler.isObservable('-----------#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c-d-e-|');
      final actual = input.lift(skip(2));
      expect(actual, scheduler.isObservable('--------c-d-e-|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c-d-e-#');
      final actual = input.lift(skip(2));
      expect(actual, scheduler.isObservable('--------c-d-e-#'));
    });
  });
  group('skipWhile', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-----|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-----#'));
    });
    test('two values and completion', () {
      final input = scheduler.cold('--a---b----|');
      final actual = input.lift(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-----------|'));
    });
    test('two values and error', () {
      final input = scheduler.cold('--a---b----#');
      final actual = input.lift(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-----------#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c-b-a-|');
      final actual = input.lift(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--------c-b-a-|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c-b-a-#');
      final actual = input.lift(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--------c-b-a-#'));
    });
  });
  group('take', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(take(2));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(take(2));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(take(2));
      expect(actual, scheduler.isObservable('--a--|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(take(2));
      expect(actual, scheduler.isObservable('--a--#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c----|');
      final actual = input.lift(take(2));
      expect(actual, scheduler.isObservable('-a--(b|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c----#');
      final actual = input.lift(take(2));
      expect(actual, scheduler.isObservable('-a--(b|)'));
    });
  });
  group('takeWhile', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--a--|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--a--#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c----|');
      final actual = input.lift(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-a--b---|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c----#');
      final actual = input.lift(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-a--b---|'));
    });
  });
  group('toList', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.lift(toList());
      expect(actual, scheduler.isObservable('--(x|)', values: {'x': []}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.lift(toList());
      expect(actual, scheduler.isObservable('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.lift(toList());
      expect(
          actual,
          scheduler.isObservable('-----(x|)', values: {
            'x': ['a']
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual = input.lift(toList());
      expect(actual, scheduler.isObservable('--x--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.lift(toList());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': ['a', 'b', 'c']
          }));
    });
    test('multiple values and error', () {
      final input = scheduler.cold<String>('--a--b--c--#');
      final actual = input.lift(toList());
      expect(actual, scheduler.isObservable('-----------#'));
    });
  });
  group('toSet', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.lift(toSet());
      expect(actual, scheduler.isObservable('--(x|)', values: {'x': {}}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.lift(toSet());
      expect(actual, scheduler.isObservable('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.lift(toSet());
      expect(
          actual,
          scheduler.isObservable('-----(x|)', values: {
            'x': {'a'}
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual = input.lift(toSet());
      expect(actual, scheduler.isObservable('--x--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.lift(toSet());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': {'a', 'b', 'c'}
          }));
    });
    test('multiple values and error', () {
      final input = scheduler.cold<String>('--a--b--c--#');
      final actual = input.lift(toSet());
      expect(actual, scheduler.isObservable('-----------#'));
    });
  });
}
