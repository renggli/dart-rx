library rx.test.operators_test;

import 'package:rx/core.dart';
import 'package:rx/operators.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart' hide isEmpty;

const Map<String, bool> boolMap = {'t': true, 'f': false};

void main() {
  final scheduler = TestScheduler();
  scheduler.install();

  group('catchError', () {});
  group('count', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(count());
      expect(actual, scheduler.isObservable('--(x|)', values: {'x': 0}));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(count());
      expect(actual, scheduler.isObservable<int>('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(count());
      expect(
          actual, scheduler.isObservable('-----------(x|)', values: {'x': 3}));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(count());
      expect(actual, scheduler.isObservable<int>('-----------#'));
    });
  });
  group('dematerialize', () {
    final values = <String, Notification<String>>{
      'a': NextNotification('a'),
      'b': NextNotification('b'),
      'c': CompleteNotification(),
      'e': ErrorNotification('Error'),
    };
    test('empty sequence', () {
      final input = scheduler.cold('-|', values: values);
      final actual = input.lift(dematerialize());
      expect(actual, scheduler.isObservable<String>('-|'));
    });
    test('error sequence', () {
      final input = scheduler.cold('-a-#', values: values);
      final actual = input.lift(dematerialize());
      expect(actual, scheduler.isObservable<String>('-a-#'));
    });
    test('values and completion', () {
      final input = scheduler.cold('-a--b---c-|', values: values);
      final actual = input.lift(dematerialize());
      expect(actual, scheduler.isObservable<String>('-a--b---|'));
    });
    test('values and error', () {
      final input = scheduler.cold('-a--b---e-|', values: values);
      final actual = input.lift(dematerialize());
      expect(actual, scheduler.isObservable<String>('-a--b---#'));
    });
  });
  group('distinct', () {
    test('all unique values', () {
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.lift(distinct());
      expect(actual, scheduler.isObservable('-a-b-c-|'));
    });
    test('continuous repeats', () {
      final input = scheduler.cold('-a-bb-ccc-|');
      final actual = input.lift(distinct());
      expect(actual, scheduler.isObservable('-a-b--c---|'));
    });
    test('overlapping repeats', () {
      final input = scheduler.cold('-a-ab-abc-#');
      final actual = input.lift(distinct());
      expect(actual, scheduler.isObservable('-a--b---c-#'));
    });
  });
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
      final input = scheduler.cold<String>('--a--|');
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
  group('materialize', () {
    final values = <String, Notification<String>>{
      'a': NextNotification('a'),
      'b': NextNotification('b'),
      'c': CompleteNotification(),
      'e': ErrorNotification('Error'),
    };
    test('empty sequence', () {
      final input = scheduler.cold<String>('-|');
      final actual = input.lift(materialize());
      expect(actual, scheduler.isObservable('-(c|)', values: values));
    });
    test('error sequence', () {
      final input = scheduler.cold<String>('-a-#');
      final actual = input.lift(materialize());
      expect(actual, scheduler.isObservable('-a-(e|)', values: values));
    });
    test('values and completion', () {
      final input = scheduler.cold<String>('-a--b---|');
      final actual = input.lift(materialize());
      expect(actual, scheduler.isObservable('-a--b---(c|)', values: values));
    });
    test('values and error', () {
      final input = scheduler.cold<String>('-a--b---#-|');
      final actual = input.lift(materialize());
      expect(actual, scheduler.isObservable('-a--b---(e|)', values: values));
    });
  });
  group('scan', () {
    group('reduce', () {
      test('values and completion', () {
        final input = scheduler.cold<String>('-a--b---c-|');
        final actual =
            input.lift(reduce((previous, value) => '$previous$value'));
        expect(
            actual,
            scheduler.isObservable('-x--y---z-|', values: {
              'x': 'a',
              'y': 'ab',
              'z': 'abc',
            }));
      });
      test('values and error', () {
        final input = scheduler.cold<String>('-a--b---c-#');
        final actual =
            input.lift(reduce((previous, value) => '$previous$value'));
        expect(
            actual,
            scheduler.isObservable('-x--y---z-#', values: {
              'x': 'a',
              'y': 'ab',
              'z': 'abc',
            }));
      });
    });
    group('fold', () {
      test('values and completion', () {
        final input = scheduler.cold<String>('-a--b---c-|');
        final actual =
            input.lift(fold('x', (previous, value) => '$previous$value'));
        expect(
            actual,
            scheduler.isObservable('-x--y---z-|', values: {
              'x': 'xa',
              'y': 'xab',
              'z': 'xabc',
            }));
      });
      test('values and error', () {
        final input = scheduler.cold<String>('-a--b---c-#');
        final actual =
            input.lift(fold('x', (previous, value) => '$previous$value'));
        expect(
            actual,
            scheduler.isObservable('-x--y---z-#', values: {
              'x': 'xa',
              'y': 'xab',
              'z': 'xabc',
            }));
      });
      test('type transformation', () {
        final input = scheduler.cold<String>('-a--b---c-|');
        final actual = input.lift(fold<String, List<String>>(
            [], (previous, value) => [...previous, value]));
        expect(
            actual,
            scheduler.isObservable('-x--y---z-|', values: {
              'x': ['a'],
              'y': ['a', 'b'],
              'z': ['a', 'b', 'c'],
            }));
      });
    });
  });
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
  group('takeLast', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(takeLast(2));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(takeLast(2));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(takeLast(2));
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.lift(takeLast(2));
      expect(actual, scheduler.isObservable('-----#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c----|');
      final actual = input.lift(takeLast(2));
      expect(actual, scheduler.isObservable('-------------(bc|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c----#');
      final actual = input.lift(takeLast(2));
      expect(actual, scheduler.isObservable('-------------#'));
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
  group('tap', () {
    test('only completion', () {
      var completed = false;
      final input = scheduler.cold('--|');
      final actual = input.lift(tap(Observer.complete(() => completed = true)));
      expect(actual, scheduler.isObservable('--|'));
      expect(completed, isTrue);
    });
    test('only error', () {
      Object erred;
      final input = scheduler.cold('--#');
      final actual =
          input.lift(tap(Observer.error((error, [stack]) => erred = error)));
      expect(actual, scheduler.isObservable('--#'));
      expect(erred, 'Error');
    });
    test('mirrors all values', () {
      final values = [];
      final input = scheduler.cold('-a--b---c-|');
      final actual = input.lift(tap(Observer.next(values.add)));
      expect(actual, scheduler.isObservable('-a--b---c-|'));
      expect(values, ['a', 'b', 'c']);
    });
    test('values and then error', () {
      final values = [];
      final input = scheduler.cold('-ab--c(de)-#');
      final actual = input.lift(tap(Observer.next(values.add)));
      expect(actual, scheduler.isObservable('-ab--c(de)-#'));
      expect(values, ['a', 'b', 'c', 'd', 'e']);
    });
    test('error during next', () {
      final customError = Exception('My Error');
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.lift(tap(Observer.next((value) {
        if (value == 'c') {
          throw customError;
        }
      })));
      expect(actual, scheduler.isObservable('-a-b-#', error: customError));
    });
    test('error during error', () {
      final customError = Exception('My Error');
      final input = scheduler.cold('-a-b-c-#');
      final actual = input.lift(tap(Observer.error((error, [stack]) {
        expect(error, 'Error');
        throw customError;
      })));
      expect(actual, scheduler.isObservable('-a-b-c-#', error: customError));
    });
    test('error during complete', () {
      final customError = Exception('My Error');
      final input = scheduler.cold('-a-b-c-|');
      final actual =
          input.lift(tap(Observer.complete(() => throw customError)));
      expect(actual, scheduler.isObservable('-a-b-c-#', error: customError));
    });
  });
  group('toList', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.lift(toList());
      expect(actual,
          scheduler.isObservable<List<String>>('--(x|)', values: {'x': []}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.lift(toList());
      expect(actual, scheduler.isObservable<List<String>>('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.lift(toList());
      expect(
          actual,
          scheduler.isObservable<List<String>>('-----(x|)', values: {
            'x': ['a']
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual = input.lift(toList());
      expect(actual, scheduler.isObservable<List<String>>('-----#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.lift(toList());
      expect(
          actual,
          scheduler.isObservable<List<String>>('-----------(x|)', values: {
            'x': ['a', 'b', 'c']
          }));
    });
    test('multiple values and error', () {
      final input = scheduler.cold<String>('--a--b--c--#');
      final actual = input.lift(toList());
      expect(actual, scheduler.isObservable<List<String>>('-----------#'));
    });
  });
  group('toSet', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.lift(toSet());
      expect(actual,
          scheduler.isObservable<Set<String>>('--(x|)', values: {'x': {}}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.lift(toSet());
      expect(actual, scheduler.isObservable<Set<String>>('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.lift(toSet());
      expect(
          actual,
          scheduler.isObservable<Set<String>>('-----(x|)', values: {
            'x': {'a'}
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual = input.lift(toSet());
      expect(actual, scheduler.isObservable<Set<String>>('-----#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.lift(toSet());
      expect(
          actual,
          scheduler.isObservable<Set<String>>('-----------(x|)', values: {
            'x': {'a', 'b', 'c'}
          }));
    });
    test('multiple values and error', () {
      final input = scheduler.cold<String>('--a--b--c--#');
      final actual = input.lift(toSet());
      expect(actual, scheduler.isObservable<Set<String>>('-----------#'));
    });
  });
}
