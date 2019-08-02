library rx.test.operators_test;

import 'package:rx/constructors.dart';
import 'package:rx/core.dart';
import 'package:rx/observables.dart';
import 'package:rx/operators.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart' hide isEmpty;

const Map<String, bool> boolMap = {'t': true, 'f': false};

bool predicate(String value) {
  if (value == 'x') {
    throw 'Error';
  }
  return value.toUpperCase() == value;
}

void main() {
  final scheduler = TestScheduler();
  setUp(scheduler.setUp);
  tearDown(scheduler.tearDown);

  group('buffer', () {
    test('no constraints', () {
      final input = scheduler.cold<String>('-a-b-c-|');
      final actual = input.pipe(buffer());
      expect(
          actual,
          scheduler.isObservable('-------(x|)', values: {
            'x': ['a', 'b', 'c']
          }));
    });
    test('max length', () {
      final input = scheduler.cold<String>('-a-b-c-d-e-|');
      final actual = input.pipe(buffer(maxLength: 2));
      expect(
          actual,
          scheduler.isObservable('---x---y---(z|)', values: {
            'x': ['a', 'b'],
            'y': ['c', 'd'],
            'z': ['e'],
          }));
    });
    test('max age', () {
      final input = scheduler.cold<String>('-a-b--cdefg|');
      final actual = input.pipe(buffer(maxAge: scheduler.stepDuration * 4));
      expect(
          actual,
          scheduler.isObservable('------x----(y|)', values: {
            'x': ['a', 'b', 'c'],
            'y': ['d', 'e', 'f', 'g'],
          }));
    });
    test('max length and age', () {
      final input = scheduler.cold<String>('-a-b--cdefg|');
      final actual =
          input.pipe(buffer(maxLength: 3, maxAge: scheduler.stepDuration * 4));
      expect(
          actual,
          scheduler.isObservable('------x--y-(z|)', values: {
            'x': ['a', 'b', 'c'],
            'y': ['d', 'e', 'f'],
            'z': ['g'],
          }));
    });
    test('trigger is shorter', () {
      final input = scheduler.cold<String>('abcdefgh|');
      final actual = input.pipe(buffer(trigger: scheduler.cold('--*--|')));
      expect(
          actual,
          scheduler.isObservable('--x-----(y|)', values: {
            'x': ['a', 'b'],
            'y': ['c', 'd', 'e', 'f', 'g', 'h'],
          }));
    });
    test('trigger is longer', () {
      final input = scheduler.cold<String>('abcdefgh|');
      final actual =
          input.pipe(buffer(trigger: scheduler.cold('--*--*--*--*--|')));
      expect(
          actual,
          scheduler.isObservable('--x--y--(z|)', values: {
            'x': ['a', 'b'],
            'y': ['c', 'd', 'e'],
            'z': ['f', 'g', 'h'],
          }));
    });
    test('error in source', () {
      final input = scheduler.cold<String>('-a-#');
      final actual = input.pipe(buffer());
      expect(actual, scheduler.isObservable<List<String>>('---#'));
    });
    test('error in trigger', () {
      final input = scheduler.cold<String>('-a-b-|');
      final actual = input.pipe(buffer(trigger: scheduler.cold('--#')));
      expect(actual, scheduler.isObservable<List<String>>('--#'));
    });
  });
  group('catchError', () {
    test('silent', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.pipe(catchError(
          (error, [stackTrace]) => fail('Not supposed to be called')));
      expect(actual, scheduler.isObservable('--a--b--c--|'));
    });
    test('completes', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual =
          input.pipe(catchError((error, [stackTrace]) => expect(error, 'A')));
      expect(actual, scheduler.isObservable('--a--b--c--|'));
    });
    test('throws different exception', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input.pipe(catchError((error, [stackTrace]) => throw 'B'));
      expect(actual, scheduler.isObservable('--a--b--c--#', error: 'B'));
    });
    test('produces alternate observable', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input.pipe(
          catchError((error, [stackTrace]) => scheduler.cold('1--2--3--|')));
      expect(actual, scheduler.isObservable('--a--b--c--1--2--3--|'));
    });
    test('produces alternate observable that throws', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input.pipe(catchError(
          (error, [stackTrace]) => scheduler.cold('1--#', error: 'B')));
      expect(actual, scheduler.isObservable('--a--b--c--1--#', error: 'B'));
    });
  });
  group('concat', () {
    group('beginWith', () {
      test('single value', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.pipe(beginWith('x'));
        expect(actual, scheduler.isObservable<String>('(xa)bc|'));
      });
      test('multiple values', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.pipe(beginWith(['x', 'y', 'z']));
        expect(actual, scheduler.isObservable<String>('(xyza)bc|'));
      });
      test('observable', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.pipe(beginWith(scheduler.cold<String>('xyz|')));
        expect(actual, scheduler.isObservable<String>('xyzabc|'));
      });
      test('error', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.pipe(beginWith(throwError<String>('Error')));
        expect(actual, scheduler.isObservable<String>('#', error: 'Error'));
      });
    });
    group('endWith', () {
      test('single value', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.pipe(endWith('x'));
        expect(actual, scheduler.isObservable<String>('abc(x|)'));
      });
      test('multiple values', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.pipe(endWith(['x', 'y', 'z']));
        expect(actual, scheduler.isObservable<String>('abc(xyz|)'));
      });
      test('observable', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.pipe(endWith(scheduler.cold<String>('xyz|')));
        expect(actual, scheduler.isObservable<String>('abcxyz|'));
      });
      test('error', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.pipe(endWith(throwError<String>('Error')));
        expect(actual, scheduler.isObservable<String>('abc#', error: 'Error'));
      });
    });
  });
  group('count', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(count());
      expect(actual, scheduler.isObservable('--(x|)', values: {'x': 0}));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.pipe(count());
      expect(actual, scheduler.isObservable<int>('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.pipe(count());
      expect(
          actual, scheduler.isObservable('-----------(x|)', values: {'x': 3}));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.pipe(count());
      expect(actual, scheduler.isObservable<int>('-----------#'));
    });
  });
  group('debounce', () {
    test('together', () {
      final input = scheduler.cold<String>('-ab----|');
      final actual = input.pipe(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('----b--|'));
    });
    test('separate', () {
      final input = scheduler.cold<String>('-a-b---|');
      final actual = input.pipe(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('-----b-|'));
    });
    test('split', () {
      final input = scheduler.cold<String>('-a--b--|');
      final actual = input.pipe(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('---a--b|'));
    });
    test('end early', () {
      final input = scheduler.cold<String>('-a|');
      final actual = input.pipe(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('--(a|)'));
    });
    test('throws error', () {
      final input = scheduler.cold<String>('-a#');
      final actual = input.pipe(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('--#'));
    });
  });
  group('defaultIfEmpty', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(defaultIfEmpty('x'));
      expect(actual, scheduler.isObservable('--(x|)'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.pipe(defaultIfEmpty('x'));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.pipe(defaultIfEmpty('x'));
      expect(actual, scheduler.isObservable('--a--b--c--|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.pipe(defaultIfEmpty('x'));
      expect(actual, scheduler.isObservable('--a--b--c--#'));
    });
  });
  group('delay', () {
    test('moderate delay', () {
      final input = scheduler.cold('-a-b--c---d----|');
      final actual = input.pipe(delay(scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable('---a-b--c---d----|'));
    });
    test('massive delay', () {
      final input = scheduler.cold('-a-b--c---d----|');
      final actual = input.pipe(delay(scheduler.stepDuration * 8));
      expect(actual, scheduler.isObservable('---------a-b--c---d----|'));
    });
    test('errors immediately', () {
      final input = scheduler.cold('-a-b--c---#');
      final actual = input.pipe(delay(scheduler.stepDuration * 4));
      expect(actual, scheduler.isObservable('-----a-b--#'));
    });
  });
  group('dematerialize', () {
    final values = <String, Event<String>>{
      'a': const NextEvent('a'),
      'b': const NextEvent('b'),
      'c': const CompleteEvent(),
      'e': const ErrorEvent('Error'),
      'f': const TestEvent(0, NextEvent('a')),
    };
    test('empty sequence', () {
      final input = scheduler.cold('-|', values: values);
      final actual = input.pipe(dematerialize());
      expect(actual, scheduler.isObservable<String>('-|'));
    });
    test('error sequence', () {
      final input = scheduler.cold('-a-#', values: values);
      final actual = input.pipe(dematerialize());
      expect(actual, scheduler.isObservable<String>('-a-#'));
    });
    test('values and completion', () {
      final input = scheduler.cold('-a--b---c-|', values: values);
      final actual = input.pipe(dematerialize());
      expect(actual, scheduler.isObservable<String>('-a--b---|'));
    });
    test('values and error', () {
      final input = scheduler.cold('-a--b---e-|', values: values);
      final actual = input.pipe(dematerialize());
      expect(actual, scheduler.isObservable<String>('-a--b---#'));
    });
    test('invalid event', () {
      final input = scheduler.cold('-a--b---f-|', values: values);
      final actual = input.pipe(dematerialize());
      expect(
          actual,
          scheduler.isObservable<String>('-a--b---#',
              error: UnexpectedEventError(values['f'])));
    });
  });
  group('distinct', () {
    test('all unique values', () {
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.pipe(distinct());
      expect(actual, scheduler.isObservable('-a-b-c-|'));
    });
    test('continuous repeats', () {
      final input = scheduler.cold('-a-bb-ccc-|');
      final actual = input.pipe(distinct());
      expect(actual, scheduler.isObservable('-a-b--c---|'));
    });
    test('overlapping repeats', () {
      final input = scheduler.cold('-a-ab-abc-#');
      final actual = input.pipe(distinct());
      expect(actual, scheduler.isObservable('-a--b---c-#'));
    });
    test('error in equals', () {
      final input = scheduler.cold<String>('-a-b-c-|');
      final actual = input
          .pipe(distinct(equals: (a, b) => throw 'Error', hashCode: (a) => 0));
      expect(actual, scheduler.isObservable<String>('-a-#'));
    });
    test('error in hash', () {
      final input = scheduler.cold<String>('-a-b-c-|');
      final actual = input.pipe(distinct(hashCode: (a) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
  });
  group('distinctUntilChanged', () {
    test('all unique values', () {
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.pipe(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b-c-|'));
    });
    test('continuous repeats', () {
      final input = scheduler.cold('-a-bb-ccc-|');
      final actual = input.pipe(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b--c---|'));
    });
    test('long repeats', () {
      final input = scheduler.cold('-(aaaaaaaaa)-(bbbbbbbbbbb)-|');
      final actual = input.pipe(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b-|'));
    });
    test('overlapping repeats', () {
      final input = scheduler.cold('-a-b-a-b-|');
      final actual = input.pipe(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b-a-b-|'));
    });
    test('coustom key', () {
      final input = scheduler.cold('-a-b-a-b-|');
      final actual = input.pipe(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b-a-b-|'));
    });
    test('complete with error', () {
      final input = scheduler.cold('-a-bb-ccc-#');
      final actual = input.pipe(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b--c---#'));
    });
    test('custom comparison', () {
      final input = scheduler.cold<String>('-(aAaA)-(BbBb)-|');
      final actual = input.pipe(distinctUntilChanged<String, String>(
          compare: (a, b) => a.toLowerCase() == b.toLowerCase()));
      expect(actual, scheduler.isObservable<String>('-a-B-|'));
    });
    test('custom comparison throws', () {
      final input = scheduler.cold<String>('-aa-|');
      final actual = input.pipe(distinctUntilChanged<String, String>(
          compare: (a, b) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-a#'));
    });
    test('custom key', () {
      final input = scheduler.cold<String>('-(aAaA)-(BbBb)-|');
      final actual = input.pipe(
          distinctUntilChanged<String, String>(key: (a) => a.toLowerCase()));
      expect(actual, scheduler.isObservable<String>('-a-B-|'));
    });
    test('custom key throws', () {
      final input = scheduler.cold<String>('-aa-|');
      final actual = input.pipe(
          distinctUntilChanged<String, String>(key: (a) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
  });
  group('exhaustAll', () {
    test('inner is shorter', () {
      final actual = scheduler.cold('-a--b--c--|', values: {
        'a': scheduler.cold<String>('x|'),
        'b': scheduler.cold<String>('y|'),
        'c': scheduler.cold<String>('z|'),
      }).pipe(exhaustAll());
      expect(actual, scheduler.isObservable<String>('-x--y--z--|'));
    });
    test('outer is shorter', () {
      final actual = scheduler.cold('-a--b--c|', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('y-|'),
        'c': scheduler.cold<String>('z-|'),
      }).pipe(exhaustAll());
      expect(actual, scheduler.isObservable<String>('-x--y--z-|'));
    });
    test('inner throws', () {
      final actual = scheduler.cold('-a--b--|', values: {
        'a': scheduler.cold<String>('x#'),
        'b': scheduler.cold<String>('y-|'),
      }).pipe(exhaustAll());
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('outer throws', () {
      final actual = scheduler.cold('-a#-b--|', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('y-|'),
      }).pipe(exhaustAll());
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('overlapping', () {
      final actual = scheduler.cold('-a-b---ba-|', values: {
        'a': scheduler.cold<String>('1-2-3|'),
        'b': scheduler.cold<String>('45|'),
      }).pipe(exhaustAll());
      expect(actual, scheduler.isObservable<String>('-1-2-3-45-|'));
    });
    test('limit concurrent', () {
      final actual = scheduler.cold('abc|', values: {
        'a': scheduler.cold<String>('x---|'),
        'b': scheduler.cold<String>('y---|'),
        'c': scheduler.cold<String>('z---|'),
      }).pipe(exhaustAll(concurrent: 2));
      expect(actual, scheduler.isObservable<String>('xy---|'));
    });
    test('invalid concurrent', () {
      expect(() => exhaustAll(concurrent: 0), throwsRangeError);
    });
  });
  group('exhaustMap', () {
    test('inner is shorter', () {
      final actual = scheduler.cold('-a--b--c--|', values: {
        'a': 'x|',
        'b': 'y|',
        'c': 'z|',
      }).pipe(exhaustMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x--y--z--|'));
    });
    test('outer is shorter', () {
      final actual = scheduler.cold('-a--b--c|', values: {
        'a': 'x-|',
        'b': 'y-|',
        'c': 'z-|',
      }).pipe(exhaustMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x--y--z-|'));
    });
    test('projection throws', () {
      final actual = scheduler
          .cold<String>('-a-b-|')
          .pipe(exhaustMap<String, String>((inner) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
    test('inner throws', () {
      final actual = scheduler.cold('-a--b--|', values: {
        'a': 'x#',
        'b': 'y-|'
      }).pipe(exhaustMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('outer throws', () {
      final actual = scheduler.cold('-a#-b--|', values: {
        'a': 'x-|',
        'b': 'y-|',
      }).pipe(exhaustMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('overlapping', () {
      final actual = scheduler.cold('-a-b---ba-|', values: {
        'a': '1-2-3|',
        'b': '45|',
      }).pipe(exhaustMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-1-2-3-45-|'));
    });
    test('limit concurrent', () {
      final actual = scheduler.cold('abc|', values: {
        'a': 'x---|',
        'b': 'y---|',
        'c': 'z---|',
      }).pipe(
          exhaustMap((inner) => scheduler.cold<String>(inner), concurrent: 2));
      expect(actual, scheduler.isObservable<String>('xy---|'));
    });
    test('invalid concurrent', () {
      expect(
          () => exhaustMap((inner) => scheduler.cold<String>(inner),
              concurrent: 0),
          throwsRangeError);
    });
  });
  group('exhaustMapTo', () {
    test('inner is shorter', () {
      final inner = scheduler.cold<String>('x|');
      final actual = scheduler.cold('-a--b--c--|').pipe(exhaustMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x--x--x--|'));
    });
    test('outer is shorter', () {
      final inner = scheduler.cold<String>('x-|');
      final actual = scheduler.cold('-a--b--c|').pipe(exhaustMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x--x--x-|'));
    });
    test('inner throws', () {
      final inner = scheduler.cold<String>('x#');
      final actual = scheduler.cold('-a--b--|').pipe(exhaustMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('outer throws', () {
      final inner = scheduler.cold<String>('x-|');
      final actual = scheduler.cold('-a#-b--|').pipe(exhaustMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('overlapping', () {
      final inner = scheduler.cold<String>('1-2-3|');
      final actual = scheduler.cold('-a-b---ba-|').pipe(exhaustMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-1-2-3-1-2-3|'));
    });
    test('limit concurrent', () {
      final inner = scheduler.cold<String>('x---|');
      final actual =
          scheduler.cold('abc|').pipe(exhaustMapTo(inner, concurrent: 2));
      expect(actual, scheduler.isObservable<String>('xx---|'));
    });
    test('invalid concurrent', () {
      expect(() => exhaustMapTo(scheduler.cold<String>(''), concurrent: 0),
          throwsRangeError);
    });
  });
  group('filter', () {
    test('first value filterd', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.pipe(filter((value) => value != 'a'));
      expect(actual, scheduler.isObservable('-----b--|'));
    });
    test('second value filtered', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.pipe(filter((value) => value != 'b'));
      expect(actual, scheduler.isObservable('--a-----|'));
    });
    test('second value filtered and error', () {
      final input = scheduler.cold('--a--b--#');
      final actual = input.pipe(filter((value) => value != 'b'));
      expect(actual, scheduler.isObservable('--a-----#'));
    });
    test('filter throws an error', () {
      final input = scheduler.cold('--a--b--#');
      final actual = input.pipe(filter((value) => throw 'Error'));
      expect(actual, scheduler.isObservable('--#'));
    });
  });
  group('finalize', () {
    test('calls finalizer on completion', () {
      final input = scheduler.cold('-a--b-|');
      var seen = false;
      final actual = input.pipe(finalize(() => seen = true));
      expect(seen, isFalse);
      expect(actual, scheduler.isObservable('-a--b-|'));
      expect(seen, isTrue);
    });
    test('calls finalizer on error', () {
      final input = scheduler.cold('-a--b-#');
      var seen = false;
      final actual = input.pipe(finalize(() => seen = true));
      expect(seen, isFalse);
      expect(actual, scheduler.isObservable('-a--b-#'));
      expect(seen, isTrue);
    });
  });
  group('first', () {
    group('first', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.pipe(first());
        expect(actual, scheduler.isObservable('--#', error: TooFewError()));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.pipe(first());
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.pipe(first());
        expect(actual, scheduler.isObservable('--(a|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.pipe(first());
        expect(actual, scheduler.isObservable('--(a|)'));
      });
    });
    group('firstOrDefault', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.pipe(firstOrDefault('x'));
        expect(actual, scheduler.isObservable('--(x|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.pipe(firstOrDefault('x'));
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.pipe(firstOrDefault('x'));
        expect(actual, scheduler.isObservable('--(a|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.pipe(firstOrDefault('x'));
        expect(actual, scheduler.isObservable('--(a|)'));
      });
    });
    group('firstOrElse', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.pipe(firstOrElse(() => 'x'));
        expect(actual, scheduler.isObservable('--(x|)'));
      });
      test('no value and completion error', () {
        final input = scheduler.cold('--|');
        final actual = input.pipe(firstOrElse(() => throw ArgumentError()));
        expect(actual, scheduler.isObservable('--#', error: ArgumentError()));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.pipe(firstOrElse(() => fail('Not called')));
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.pipe(firstOrElse(() => fail('Not called')));
        expect(actual, scheduler.isObservable('--(a|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.pipe(firstOrElse(() => fail('Not called')));
        expect(actual, scheduler.isObservable('--(a|)'));
      });
    });
    group('findFirst', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.pipe(findFirst(predicate));
        expect(actual,
            scheduler.isObservable<String>('--#', error: TooFewError()));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.pipe(findFirst(predicate));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.pipe(findFirst(predicate));
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.pipe(findFirst<String>(predicate));
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.pipe(findFirst<String>(predicate));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
    group('findFirstOrDefault', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.pipe(findFirstOrDefault(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('--(y|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.pipe(findFirstOrDefault(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.pipe(findFirstOrDefault(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.pipe(findFirstOrDefault<String>(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.pipe(findFirstOrDefault<String>(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
    group('findFirstOrElse', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.pipe(findFirstOrElse(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('--(y|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.pipe(findFirstOrElse(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('no value and completion error', () {
        final input = scheduler.cold<String>('--|');
        final actual =
            input.pipe(findFirstOrElse(predicate, () => throw ArgumentError()));
        expect(actual,
            scheduler.isObservable<String>('--#', error: ArgumentError()));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.pipe(findFirstOrElse(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual =
            input.pipe(findFirstOrElse<String>(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual =
            input.pipe(findFirstOrElse<String>(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
  });
  group('ignoreElements', () {
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.pipe(ignoreElements());
      expect(actual, scheduler.isObservable('-----------|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.pipe(ignoreElements());
      expect(actual, scheduler.isObservable('-----------#'));
    });
  });
  group('isEmpty', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(isEmpty());
      expect(actual, scheduler.isObservable('--(t|)', values: boolMap));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.pipe(isEmpty());
      expect(actual, scheduler.isObservable('--#', values: boolMap));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(isEmpty());
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.pipe(isEmpty());
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.pipe(isEmpty());
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.pipe(isEmpty());
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
  });
  group('last', () {
    group('last', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.pipe(last());
        expect(actual, scheduler.isObservable('--#', error: TooFewError()));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.pipe(last());
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.pipe(last());
        expect(actual, scheduler.isObservable('-----------(c|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.pipe(last());
        expect(actual, scheduler.isObservable('-----------#'));
      });
    });
    group('lastOrDefault', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.pipe(lastOrDefault('x'));
        expect(actual, scheduler.isObservable('--(x|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.pipe(lastOrDefault('x'));
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.pipe(lastOrDefault('x'));
        expect(actual, scheduler.isObservable('-----------(c|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.pipe(lastOrDefault('x'));
        expect(actual, scheduler.isObservable('-----------#'));
      });
    });
    group('lastOrElse', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.pipe(lastOrElse(() => 'x'));
        expect(actual, scheduler.isObservable('--(x|)'));
      });
      test('no value and completion error', () {
        final input = scheduler.cold('--|');
        final actual = input.pipe(lastOrElse(() => throw ArgumentError()));
        expect(actual, scheduler.isObservable('--#', error: ArgumentError()));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.pipe(lastOrElse(() => fail('Not called')));
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.pipe(lastOrElse(() => fail('Not called')));
        expect(actual, scheduler.isObservable('-----------(c|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.pipe(lastOrElse(() => fail('Not called')));
        expect(actual, scheduler.isObservable('-----------#'));
      });
    });
    group('findLast', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.pipe(findLast(predicate));
        expect(actual,
            scheduler.isObservable<String>('--#', error: TooFewError()));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.pipe(findLast(predicate));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.pipe(findLast(predicate));
        expect(actual, scheduler.isObservable<String>('-----------(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.pipe(findLast<String>(predicate));
        expect(actual, scheduler.isObservable<String>('-----------#'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.pipe(findLast<String>(predicate));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
    group('findLastOrDefault', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.pipe(findLastOrDefault(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('--(y|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.pipe(findLastOrDefault(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.pipe(findLastOrDefault(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('-----------(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.pipe(findLastOrDefault<String>(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('-----------#'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.pipe(findLastOrDefault<String>(predicate, 'y'));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
    group('findLastOrElse', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.pipe(findLastOrElse(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('--(y|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.pipe(findLastOrElse(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('no value and completion error', () {
        final input = scheduler.cold<String>('--|');
        final actual =
            input.pipe(findLastOrElse(predicate, () => throw ArgumentError()));
        expect(actual,
            scheduler.isObservable<String>('--#', error: ArgumentError()));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.pipe(findLastOrElse(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('-----------(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.pipe(findLastOrElse<String>(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('-----------#'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.pipe(findLastOrElse<String>(predicate, () => 'y'));
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
  });
  group('map', () {
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.pipe(map((value) => '$value!'));
      expect(actual, scheduler.isObservable('--a--|', values: {'a': 'a!'}));
    });
    test('single value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.pipe(map((value) => '$value!'));
      expect(actual, scheduler.isObservable('--a--#', values: {'a': 'a!'}));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.pipe(map((value) => '$value!'));
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': 'a!', 'b': 'b!', 'c': 'c!'}));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.pipe(map((value) => '$value!'));
      expect(
          actual,
          scheduler.isObservable('--a--b--c--#',
              values: {'a': 'a!', 'b': 'b!', 'c': 'c!'}));
    });
    test('mapper throws error', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe(map<String, String>((value) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('--#'));
    });
  });
  group('mapTo', () {
    test('single value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--|'));
    });
    test('single value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.pipe(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.pipe(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--x--x--|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.pipe(mapTo('x'));
      expect(actual, scheduler.isObservable<String>('--x--x--x--#'));
    });
  });
  group('materialize', () {
    final values = <String, Event<String>>{
      'a': const NextEvent('a'),
      'b': const NextEvent('b'),
      'c': const CompleteEvent(),
      'e': const ErrorEvent('Error'),
    };
    test('empty sequence', () {
      final input = scheduler.cold<String>('-|');
      final actual = input.pipe(materialize());
      expect(actual, scheduler.isObservable('-(c|)', values: values));
    });
    test('error sequence', () {
      final input = scheduler.cold<String>('-a-#');
      final actual = input.pipe(materialize());
      expect(actual, scheduler.isObservable('-a-(e|)', values: values));
    });
    test('values and completion', () {
      final input = scheduler.cold<String>('-a--b---|');
      final actual = input.pipe(materialize());
      expect(actual, scheduler.isObservable('-a--b---(c|)', values: values));
    });
    test('values and error', () {
      final input = scheduler.cold<String>('-a--b---#-|');
      final actual = input.pipe(materialize());
      expect(actual, scheduler.isObservable('-a--b---(e|)', values: values));
    });
  });
  group('mergeAll', () {
    test('inner with dynamic outputs', () {
      final actual = scheduler.cold('-a--b---c---a--|', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('yy-|'),
        'c': scheduler.cold<String>('zzz-|'),
      }).pipe(mergeAll());
      expect(actual, scheduler.isObservable<String>('-x--yy--zzz-x--|'));
    });
    test('inner with error', () {
      final actual = scheduler.cold('-a--b---c---a--|', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('yy-|'),
        'c': scheduler.cold<String>('zz#'),
      }).pipe(mergeAll());
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('outer with error', () {
      final actual = scheduler.cold('-a--b---c-#', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('yy-|'),
        'c': scheduler.cold<String>('zz#'),
      }).pipe(mergeAll());
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('limit concurrent', () {
      final actual = scheduler.cold('abc|', values: {
        'a': scheduler.cold<String>('x---|'),
        'b': scheduler.cold<String>('y---|'),
        'c': scheduler.cold<String>('z---|'),
      }).pipe(mergeAll(concurrent: 2));
      expect(actual, scheduler.isObservable<String>('xy--z---|'));
    });
    test('invalid concurrent', () {
      expect(
          () =>
              mergeMap((inner) => scheduler.cold<String>(inner), concurrent: 0),
          throwsRangeError);
    });
  });
  group('mergeMap', () {
    test('inner with dynamic outputs', () {
      final actual = scheduler.cold<String>('-a--b---c---a--|', values: {
        'a': 'x-|',
        'b': 'yy-|',
        'c': 'zzz-|',
      }).pipe(mergeMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x--yy--zzz-x--|'));
    });
    test('projection throws', () {
      final actual = scheduler
          .cold<String>('-a-|')
          .pipe(mergeMap<String, String>((inner) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
    test('inner with error', () {
      final actual = scheduler.cold('-a--b---c---a--|', values: {
        'a': 'x-|',
        'b': 'yy-|',
        'c': 'zz#',
      }).pipe(mergeMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('outer with error', () {
      final actual = scheduler.cold('-a--b---c-#', values: {
        'a': 'x-|',
        'b': 'yy-|',
        'c': 'zz#',
      }).pipe(mergeMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('limit concurrent', () {
      final actual = scheduler.cold('abc|', values: {
        'a': 'x---|',
        'b': 'y---|',
        'c': 'z---|',
      }).pipe(
          mergeMap((inner) => scheduler.cold<String>(inner), concurrent: 2));
      expect(actual, scheduler.isObservable<String>('xy--z---|'));
    });
    test('invalid concurrent', () {
      expect(
          () =>
              mergeMap((inner) => scheduler.cold<String>(inner), concurrent: 0),
          throwsRangeError);
    });
  });
  group('mergeMapTo', () {
    test('inner emits a single value', () {
      final inner = just('x');
      final actual = scheduler.cold('-a--a---a-|').pipe(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x--x---x-|'));
    });
    test('inner emits two values', () {
      final inner = scheduler.cold<String>('x-y-|');
      final actual = scheduler.cold('-a--a---a-|').pipe(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x-yx-y-x-y-|'));
    });
    test('inner started concurrently', () {
      final inner = scheduler.cold<String>('x-y-|');
      final actual = scheduler.cold('-(ab)--|').pipe(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-(xx)-(yy)-|'));
    });
    test('inner started overlappingly', () {
      final inner = scheduler.cold<String>('x-y-|');
      final actual = scheduler.cold('-ab-|').pipe(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-xxyy-|'));
    });
    test('inner throws', () {
      final inner = scheduler.cold<String>('x---#');
      final actual = scheduler.cold('-a-b-|').pipe(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x-x-#'));
    });
    test('outer throws', () {
      final inner = scheduler.cold<String>('x-y-z-|');
      final actual = scheduler.cold('-a--#').pipe(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x-y#'));
    });
    test('limit concurrent', () {
      final inner = scheduler.cold<String>('xyz|');
      final actual =
          scheduler.cold('a---b---|').pipe(mergeMapTo(inner, concurrent: 1));
      expect(actual, scheduler.isObservable<String>('xyz-xyz-|'));
    });
    test('invalid concurrent', () {
      expect(() => mergeMapTo(scheduler.cold(''), concurrent: 0),
          throwsRangeError);
    });
  });
  group('multicast', () {
    group('publishBehavior', () {
      test('incomplete sequence', () {
        final source = scheduler.cold<String>('-a-b-c-');
        final actual =
            source.pipe(publishBehavior('x')) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>('x'));
        actual.connect();
        expect(actual, scheduler.isObservable<String>('xa-b-c-'));
        expect(actual, scheduler.isObservable<String>('c'));
      });
      test('completed sequence', () {
        final source = scheduler.cold<String>('-a-b-c-|');
        final actual =
            source.pipe(publishBehavior('x')) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>('x'));
        actual.connect();
        expect(actual, scheduler.isObservable<String>('xa-b-c-|'));
        expect(actual, scheduler.isObservable<String>('(c|)'));
      });
      test('errored sequence', () {
        final source = scheduler.cold<String>('-a-b-c-#');
        final actual =
            source.pipe(publishBehavior('x')) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>('x'));
        actual.connect();
        expect(actual, scheduler.isObservable<String>('xa-b-c-#'));
        expect(actual, scheduler.isObservable<String>('#'));
      });
    });
    group('publishLast', () {
      test('incomplete sequence', () {
        final source = scheduler.cold<String>('-a-b-c-');
        final actual = source.pipe(publishLast()) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>(''));
        actual.connect();
        expect(actual, scheduler.isObservable<String>(''));
        expect(actual, scheduler.isObservable<String>(''));
      });
      test('completed sequence', () {
        final source = scheduler.cold<String>('-a-b-c-|');
        final actual = source.pipe(publishLast()) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>(''));
        actual.connect();
        expect(actual, scheduler.isObservable<String>('-------(c|)'));
        expect(actual, scheduler.isObservable<String>('(c|)'));
      });
      test('errored sequence', () {
        final source = scheduler.cold<String>('-a-b-c-#');
        final actual = source.pipe(publishLast()) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>(''));
        actual.connect();
        expect(actual, scheduler.isObservable<String>('-------#'));
        expect(actual, scheduler.isObservable<String>('#'));
      });
    });
    group('publishReplay', () {
      test('incomplete sequence', () {
        final source = scheduler.cold<String>('-a-b-c-');
        final actual = source.pipe(publishReplay()) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>(''));
        actual.connect();
        expect(actual, scheduler.isObservable<String>('-a-b-c-'));
        expect(actual, scheduler.isObservable<String>('(abc)'));
      });
      test('completed sequence', () {
        final source = scheduler.cold<String>('-a-b-c-|');
        final actual = source.pipe(publishReplay()) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>(''));
        actual.connect();
        expect(actual, scheduler.isObservable<String>('-a-b-c-|'));
        expect(actual, scheduler.isObservable<String>('(abc|)'));
      });
      test('errored sequence', () {
        final source = scheduler.cold<String>('-a-b-c-#');
        final actual = source.pipe(publishReplay()) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>(''));
        actual.connect();
        expect(actual, scheduler.isObservable<String>('-a-b-c-#'));
        expect(actual, scheduler.isObservable<String>('#'));
      });
      test('limited sequence', () {
        final source = scheduler.cold<String>('-a-b-c-');
        final actual =
            source.pipe(publishReplay(bufferSize: 2)) as ConnectableObservable;
        expect(actual, scheduler.isObservable<String>(''));
        actual.connect();
        expect(actual, scheduler.isObservable<String>('-a-b-c-'));
        expect(actual, scheduler.isObservable<String>('(bc)'));
      });
    });
  });
  group('observeOn', () {
    test('plain sequence', () {
      final actual = scheduler
          .cold<String>('-a-b-c-|')
          .pipe(observeOn(ImmediateScheduler()));
      expect(actual, scheduler.isObservable<String>('-a-b-c-|'));
    });
    test('sequence with delay', () {
      final actual = scheduler
          .cold<String>('-a-b-c-|')
          .pipe(observeOn(scheduler, delay: scheduler.stepDuration));
      expect(actual, scheduler.isObservable<String>('--a-b-c-|'));
    });
    test('error sequence', () {
      final actual = scheduler
          .cold<String>('-a-b-c-#')
          .pipe(observeOn(ImmediateScheduler()));
      expect(actual, scheduler.isObservable<String>('-a-b-c-#'));
    });
    test('error with delay', () {
      final actual = scheduler
          .cold<String>('-a-b-c-#')
          .pipe(observeOn(scheduler, delay: scheduler.stepDuration));
      expect(actual, scheduler.isObservable<String>('--a-b-c-#'));
    });
  });
  group('refCount', () {
    test('failure', () {});
  });
  group('sample', () {
    test('samples on value trigger', () {
      final actual = scheduler
          .cold<String>('-a-b-c---d-|')
          .pipe(sample(scheduler.cold('--x---x-x-x--|')));
      expect(actual, scheduler.isObservable<String>('--a---c---d|'));
    });
    test('samples on completion of trigger', () {
      final actual = scheduler
          .cold<String>('-a-b-c---d-|')
          .pipe(sample(scheduler.cold('--x---x-x-|')));
      expect(actual, scheduler.isObservable<String>('--a---c---d|'));
    });
    test('input throws', () {
      final actual =
          scheduler.cold<String>('-#').pipe(sample(scheduler.cold('-x-|')));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
    test('trigger throws', () {
      final actual = scheduler
          .cold<String>('-a-b-c---d-|')
          .pipe(sample(scheduler.cold('--#')));
      expect(actual, scheduler.isObservable<String>('--#'));
    });
  });
  group('scan', () {
    group('reduce', () {
      test('values and completion', () {
        final input = scheduler.cold<String>('-a--b---c-|');
        final actual =
            input.pipe(reduce((previous, value) => '$previous$value'));
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
            input.pipe(reduce((previous, value) => '$previous$value'));
        expect(
            actual,
            scheduler.isObservable('-x--y---z-#', values: {
              'x': 'a',
              'y': 'ab',
              'z': 'abc',
            }));
      });
      test('error in computation', () {
        final input = scheduler.cold<String>('-a-b-c-|');
        final actual =
            input.pipe(reduce<String>((previous, value) => throw 'Error'));
        expect(actual, scheduler.isObservable<String>('-a-#'));
      });
    });
    group('fold', () {
      test('values and completion', () {
        final input = scheduler.cold<String>('-a--b---c-|');
        final actual =
            input.pipe(fold('x', (previous, value) => '$previous$value'));
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
            input.pipe(fold('x', (previous, value) => '$previous$value'));
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
        final actual = input.pipe(fold<String, List<String>>(
            [], (previous, value) => [...previous, value]));
        expect(
            actual,
            scheduler.isObservable('-x--y---z-|', values: {
              'x': ['a'],
              'y': ['a', 'b'],
              'z': ['a', 'b', 'c'],
            }));
      });
      test('error in computation', () {
        final input = scheduler.cold<String>('-a-b-c-|');
        final actual =
            input.pipe(fold('x', (previous, value) => throw 'Error'));
        expect(actual, scheduler.isObservable<String>('-#'));
      });
    });
  });
  group('single', () {
    test('no elements', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(single());
      expect(actual, scheduler.isObservable('--#', error: TooFewError()));
    });
    test('one element', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(single());
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('two elements', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.pipe(single());
      expect(actual, scheduler.isObservable('-----#', error: TooManyError()));
    });
  });
  group('singleOrDefault', () {
    test('no elements', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(singleOrDefault(tooFew: 'f', tooMany: 'm'));
      expect(actual, scheduler.isObservable('--(f|)'));
    });
    test('one element', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(singleOrDefault(tooFew: 'f', tooMany: 'm'));
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('two elements', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.pipe(singleOrDefault(tooFew: 'f', tooMany: 'm'));
      expect(actual, scheduler.isObservable('-----(m|)'));
    });
  });
  group('singleOrElse', () {
    final tooFew = StateError('Few');
    final tooMany = StateError('Many');
    test('no elements', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(singleOrElse(
          tooFew: () => throw tooFew, tooMany: () => throw tooMany));
      expect(actual, scheduler.isObservable('--#', error: tooFew));
    });
    test('one element', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(singleOrElse(
          tooFew: () => throw tooFew, tooMany: () => throw tooMany));
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('two elements', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.pipe(singleOrElse(
          tooFew: () => throw tooFew, tooMany: () => throw tooMany));
      expect(actual, scheduler.isObservable('-----#', error: tooMany));
    });
  });
  group('skip', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(skip(2));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.pipe(skip(2));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(skip(2));
      expect(actual, scheduler.isObservable('-----|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.pipe(skip(2));
      expect(actual, scheduler.isObservable('-----#'));
    });
    test('two values and completion', () {
      final input = scheduler.cold('--a---b----|');
      final actual = input.pipe(skip(2));
      expect(actual, scheduler.isObservable('-----------|'));
    });
    test('two values and error', () {
      final input = scheduler.cold('--a---b----#');
      final actual = input.pipe(skip(2));
      expect(actual, scheduler.isObservable('-----------#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c-d-e-|');
      final actual = input.pipe(skip(2));
      expect(actual, scheduler.isObservable('--------c-d-e-|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c-d-e-#');
      final actual = input.pipe(skip(2));
      expect(actual, scheduler.isObservable('--------c-d-e-#'));
    });
  });
  group('skipWhile', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.pipe(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-----|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.pipe(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-----#'));
    });
    test('two values and completion', () {
      final input = scheduler.cold('--a---b----|');
      final actual = input.pipe(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-----------|'));
    });
    test('two values and error', () {
      final input = scheduler.cold('--a---b----#');
      final actual = input.pipe(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-----------#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c-b-a-|');
      final actual = input.pipe(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--------c-b-a-|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c-b-a-#');
      final actual = input.pipe(skipWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--------c-b-a-#'));
    });
    test('predicate throws error', () {
      final input = scheduler.cold<String>('-a-|');
      final actual = input.pipe(skipWhile((value) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
  });
  group('switchAll', () {
    final observables = {
      '1': scheduler.cold<String>('x|'),
      '2': scheduler.cold<String>('xy|'),
      '3': scheduler.cold<String>('xyz|'),
      '4': scheduler.cold<String>('xyz#'),
    };
    test('outer longer', () {
      final input = scheduler.cold('-1---2---3---|', values: observables);
      final actual = input.pipe(switchAll());
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz-|'));
    });
    test('inner longer', () {
      final input = scheduler.cold('-1---2---3|', values: observables);
      final actual = input.pipe(switchAll());
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz|'));
    });
    test('outer error', () {
      final input = scheduler.cold('-3#', values: observables);
      final actual = input.pipe(switchAll());
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('inner error', () {
      final input = scheduler.cold('-4--4---4---|', values: observables);
      final actual = input.pipe(switchAll());
      expect(actual, scheduler.isObservable<String>('-xyzxyz#'));
    });
    test('overlapping', () {
      final input = scheduler.cold('-3--3-33--|', values: observables);
      final actual = input.pipe(switchAll());
      expect(actual, scheduler.isObservable<String>('-xyzxyxxyz|'));
    });
  });
  group('switchMap', () {
    final marbles = {
      '1': 'x|',
      '2': 'xy|',
      '3': 'xyz|',
      '4': 'xyz#',
    };
    test('outer longer', () {
      final input = scheduler.cold('-1---2---3---|', values: marbles);
      final actual =
          input.pipe(switchMap((marble) => scheduler.cold<String>(marble)));
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz-|'));
    });
    test('inner longer', () {
      final input = scheduler.cold('-1---2---3|', values: marbles);
      final actual =
          input.pipe(switchMap((marble) => scheduler.cold<String>(marble)));
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz|'));
    });
    test('outer error', () {
      final input = scheduler.cold('-3#', values: marbles);
      final actual =
          input.pipe(switchMap((marble) => scheduler.cold<String>(marble)));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('inner error', () {
      final input = scheduler.cold('-4--4---4---|', values: marbles);
      final actual =
          input.pipe(switchMap((marble) => scheduler.cold<String>(marble)));
      expect(actual, scheduler.isObservable<String>('-xyzxyz#'));
    });
    test('project error', () {
      final input = scheduler.cold('-123-|');
      final actual = input.pipe(switchMap((observable) => throw 'Error'));
      expect(actual, scheduler.isObservable('-#'));
    });
    test('overlapping', () {
      final input = scheduler.cold('-3--3-33--|', values: marbles);
      final actual =
          input.pipe(switchMap((marble) => scheduler.cold<String>(marble)));
      expect(actual, scheduler.isObservable<String>('-xyzxyxxyz|'));
    });
  });
  group('switchMapTo', () {
    test('outer longer', () {
      final input = scheduler.cold('-a---a---a---|');
      final actual = input.pipe(switchMapTo(scheduler.cold<String>('xyz|')));
      expect(actual, scheduler.isObservable<String>('-xyz-xyz-xyz-|'));
    });
    test('inner longer', () {
      final input = scheduler.cold('-a---a---a|');
      final actual = input.pipe(switchMapTo(scheduler.cold<String>('xyz|')));
      expect(actual, scheduler.isObservable<String>('-xyz-xyz-xyz|'));
    });
    test('outer error', () {
      final input = scheduler.cold('-a#');
      final actual = input.pipe(switchMapTo(scheduler.cold<String>('xyz|')));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('inner error', () {
      final input = scheduler.cold('-a--a---a---|');
      final actual = input.pipe(switchMapTo(scheduler.cold<String>('xyz#')));
      expect(actual, scheduler.isObservable<String>('-xyzxyz#'));
    });
    test('overlapping', () {
      final input = scheduler.cold('-a--a-aa--|');
      final actual = input.pipe(switchMapTo(scheduler.cold<String>('xyz|')));
      expect(actual, scheduler.isObservable<String>('-xyzxyxxyz|'));
    });
  });
  group('take', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(take(2));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.pipe(take(2));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(take(2));
      expect(actual, scheduler.isObservable('--a--|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.pipe(take(2));
      expect(actual, scheduler.isObservable('--a--#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c----|');
      final actual = input.pipe(take(2));
      expect(actual, scheduler.isObservable('-a--(b|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c----#');
      final actual = input.pipe(take(2));
      expect(actual, scheduler.isObservable('-a--(b|)'));
    });
  });
  group('takeLast', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(takeLast(2));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.pipe(takeLast(2));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(takeLast(2));
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.pipe(takeLast(2));
      expect(actual, scheduler.isObservable('-----#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c----|');
      final actual = input.pipe(takeLast(2));
      expect(actual, scheduler.isObservable('-------------(bc|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c----#');
      final actual = input.pipe(takeLast(2));
      expect(actual, scheduler.isObservable('-------------#'));
    });
  });
  group('takeWhile', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.pipe(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.pipe(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--a--|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.pipe(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('--a--#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c----|');
      final actual = input.pipe(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-a--b---|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c----#');
      final actual = input.pipe(takeWhile((value) => 'ab'.contains(value)));
      expect(actual, scheduler.isObservable('-a--b---|'));
    });
    test('predicate throws error', () {
      final input = scheduler.cold<String>('-a-|');
      final actual = input.pipe(takeWhile((value) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
  });
  group('tap', () {
    test('only completion', () {
      var completed = false;
      final input = scheduler.cold('--|');
      final actual = input.pipe(tap(Observer.complete(() => completed = true)));
      expect(actual, scheduler.isObservable('--|'));
      expect(completed, isTrue);
    });
    test('only error', () {
      Object erred;
      final input = scheduler.cold('--#');
      final actual =
          input.pipe(tap(Observer.error((error, [stack]) => erred = error)));
      expect(actual, scheduler.isObservable('--#'));
      expect(erred, 'Error');
    });
    test('mirrors all values', () {
      final values = [];
      final input = scheduler.cold('-a--b---c-|');
      final actual = input.pipe(tap(Observer.next(values.add)));
      expect(actual, scheduler.isObservable('-a--b---c-|'));
      expect(values, ['a', 'b', 'c']);
    });
    test('values and then error', () {
      final values = [];
      final input = scheduler.cold('-ab--c(de)-#');
      final actual = input.pipe(tap(Observer.next(values.add)));
      expect(actual, scheduler.isObservable('-ab--c(de)-#'));
      expect(values, ['a', 'b', 'c', 'd', 'e']);
    });
    test('error during next', () {
      final customError = Exception('My Error');
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.pipe(tap(Observer.next((value) {
        if (value == 'c') {
          throw customError;
        }
      })));
      expect(actual, scheduler.isObservable('-a-b-#', error: customError));
    });
    test('error during error', () {
      final customError = Exception('My Error');
      final input = scheduler.cold('-a-b-c-#');
      final actual = input.pipe(tap(Observer.error((error, [stack]) {
        expect(error, 'Error');
        throw customError;
      })));
      expect(actual, scheduler.isObservable('-a-b-c-#', error: customError));
    });
    test('error during complete', () {
      final customError = Exception('My Error');
      final input = scheduler.cold('-a-b-c-|');
      final actual =
          input.pipe(tap(Observer.complete(() => throw customError)));
      expect(actual, scheduler.isObservable('-a-b-c-#', error: customError));
    });
  });
  group('timeout', () {
    test('after immediate completion', () {
      final input = scheduler.cold('--|');
      final actual = input.pipe(timeout(scheduler.stepDuration * 3));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('after immediate error', () {
      final input = scheduler.cold('--#');
      final actual = input.pipe(timeout(scheduler.stepDuration * 3));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('after emission and completion', () {
      final input = scheduler.cold('ab|');
      final actual = input.pipe(timeout(scheduler.stepDuration * 3));
      expect(actual, scheduler.isObservable('ab|'));
    });
    test('after emission and error', () {
      final input = scheduler.cold('ab#');
      final actual = input.pipe(timeout(scheduler.stepDuration * 3));
      expect(actual, scheduler.isObservable('ab#'));
    });
    test('before immediate completion', () {
      final input = scheduler.cold('----|');
      final actual = input.pipe(timeout(scheduler.stepDuration * 3));
      expect(actual, scheduler.isObservable('---#', error: TimeoutError()));
    });
    test('before immediate error', () {
      final input = scheduler.cold('----#');
      final actual = input.pipe(timeout(scheduler.stepDuration * 3));
      expect(actual, scheduler.isObservable('---#', error: TimeoutError()));
    });
    test('before emission and completion', () {
      final input = scheduler.cold('abcd|');
      final actual = input.pipe(timeout(scheduler.stepDuration * 3));
      expect(actual, scheduler.isObservable('abc#', error: TimeoutError()));
    });
    test('before emission and error', () {
      final input = scheduler.cold('abcd#');
      final actual = input.pipe(timeout(scheduler.stepDuration * 3));
      expect(actual, scheduler.isObservable('abc#', error: TimeoutError()));
    });
  });
  group('toList', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.pipe(toList());
      expect(actual,
          scheduler.isObservable<List<String>>('--(x|)', values: {'x': []}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.pipe(toList());
      expect(actual, scheduler.isObservable<List<String>>('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.pipe(toList());
      expect(
          actual,
          scheduler.isObservable('-----(x|)', values: {
            'x': ['a']
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual = input.pipe(toList());
      expect(actual, scheduler.isObservable<List<String>>('-----#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe(toList());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': ['a', 'b', 'c']
          }));
    });
    test('multiple values and error', () {
      final input = scheduler.cold<String>('--a--b--c--#');
      final actual = input.pipe(toList());
      expect(actual, scheduler.isObservable<List<String>>('-----------#'));
    });
    test('custom constructor', () {
      var creation = 0;
      final input = scheduler.cold<String>('abc|');
      final actual = input.pipe(toList(() {
        creation++;
        return <String>[];
      }));
      expect(creation, 0);
      expect(
          actual,
          scheduler.isObservable('---(x|)', values: {
            'x': ['a', 'b', 'c']
          }));
      expect(creation, 1);
    });
  });
  group('toSet', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.pipe(toSet());
      expect(actual,
          scheduler.isObservable<Set<String>>('--(x|)', values: {'x': {}}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.pipe(toSet());
      expect(actual, scheduler.isObservable<Set<String>>('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.pipe(toSet());
      expect(
          actual,
          scheduler.isObservable('-----(x|)', values: {
            'x': {'a'}
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual = input.pipe(toSet());
      expect(actual, scheduler.isObservable<Set<String>>('-----#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe(toSet());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': {'a', 'b', 'c'}
          }));
    });
    test('multiple values and error', () {
      final input = scheduler.cold<String>('--a--b--c--#');
      final actual = input.pipe(toSet());
      expect(actual, scheduler.isObservable<Set<String>>('-----------#'));
    });
    test('custom constructor', () {
      var creation = 0;
      final input = scheduler.cold<String>('abc|');
      final actual = input.pipe(toSet(() {
        creation++;
        return <String>{};
      }));
      expect(creation, 0);
      expect(
          actual,
          scheduler.isObservable('---(x|)', values: {
            'x': {'a', 'b', 'c'}
          }));
      expect(creation, 1);
    });
  });
}
