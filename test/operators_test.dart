library rx.test.operators_test;

import 'package:rx/constructors.dart';
import 'package:rx/core.dart';
import 'package:rx/operators.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart' hide isEmpty;

const Map<String, bool> boolMap = {'t': true, 'f': false};

void main() {
  final scheduler = TestScheduler();
  scheduler.install();

  group('buffer', () {
    test('no constraints', () {
      final input = scheduler.cold<String>('-a-b-c-|');
      final actual = input.lift(buffer());
      expect(
          actual,
          scheduler.isObservable<List<String>>('-------(x|)', values: {
            'x': ['a', 'b', 'c']
          }));
    });
    test('max length', () {
      final input = scheduler.cold<String>('-a-b-c-d-e-|');
      final actual = input.lift(buffer(maxLength: 2));
      expect(
          actual,
          scheduler.isObservable<List<String>>('---x---y---(z|)', values: {
            'x': ['a', 'b'],
            'y': ['c', 'd'],
            'z': ['e'],
          }));
    });
    test('max age', () {
      final input = scheduler.cold<String>('-a-b--cdefg|');
      final actual = input.lift(buffer(maxAge: scheduler.stepDuration * 4));
      expect(
          actual,
          scheduler.isObservable<List<String>>('------x----(y|)', values: {
            'x': ['a', 'b', 'c'],
            'y': ['d', 'e', 'f', 'g'],
          }));
    });
    test('max length and age', () {
      final input = scheduler.cold<String>('-a-b--cdefg|');
      final actual =
          input.lift(buffer(maxLength: 3, maxAge: scheduler.stepDuration * 4));
      expect(
          actual,
          scheduler.isObservable<List<String>>('------x--y-(z|)', values: {
            'x': ['a', 'b', 'c'],
            'y': ['d', 'e', 'f'],
            'z': ['g'],
          }));
    });
    test('trigger is shorter', () {
      final input = scheduler.cold<String>('abcdefgh|');
      final actual = input.lift(buffer(trigger: scheduler.cold('--*--|')));
      expect(
          actual,
          scheduler.isObservable<List<String>>('--x-----(y|)', values: {
            'x': ['a', 'b'],
            'y': ['c', 'd', 'e', 'f', 'g', 'h'],
          }));
    });
    test('trigger is longer', () {
      final input = scheduler.cold<String>('abcdefgh|');
      final actual =
          input.lift(buffer(trigger: scheduler.cold('--*--*--*--*--|')));
      expect(
          actual,
          scheduler.isObservable<List<String>>('--x--y--(z|)', values: {
            'x': ['a', 'b'],
            'y': ['c', 'd', 'e'],
            'z': ['f', 'g', 'h'],
          }));
    });
    test('error in source', () {
      final input = scheduler.cold<String>('-a-#');
      final actual = input.lift(buffer());
      expect(actual, scheduler.isObservable<List<String>>('---#'));
    });
    test('error in trigger', () {
      final input = scheduler.cold<String>('-a-b-|');
      final actual = input.lift(buffer(trigger: scheduler.cold('--#')));
      expect(actual, scheduler.isObservable<List<String>>('--#'));
    });
  });
  group('catchError', () {
    test('silent', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(catchError(
          (error, [stackTrace]) => fail('Not supposed to be called')));
      expect(actual, scheduler.isObservable('--a--b--c--|'));
    });
    test('completes', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual =
          input.lift(catchError((error, [stackTrace]) => expect(error, 'A')));
      expect(actual, scheduler.isObservable('--a--b--c--|'));
    });
    test('throws different exception', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input.lift(catchError((error, [stackTrace]) => throw 'B'));
      expect(actual, scheduler.isObservable('--a--b--c--#', error: 'B'));
    });
    test('produces alternate observable', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input.lift(
          catchError((error, [stackTrace]) => scheduler.cold('1--2--3--|')));
      expect(actual, scheduler.isObservable('--a--b--c--1--2--3--|'));
    });
    test('produces alternate observable that throws', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input.lift(catchError(
          (error, [stackTrace]) => scheduler.cold('1--#', error: 'B')));
      expect(actual, scheduler.isObservable('--a--b--c--1--#', error: 'B'));
    });
  });
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
  group('debounce', () {
    test('together', () {
      final input = scheduler.cold<String>('-ab----|');
      final actual = input.lift(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('----b--|'));
    });
    test('separate', () {
      final input = scheduler.cold<String>('-a-b---|');
      final actual = input.lift(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('-----b-|'));
    });
    test('split', () {
      final input = scheduler.cold<String>('-a--b--|');
      final actual = input.lift(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('---a--b|'));
    });
    test('end early', () {
      final input = scheduler.cold<String>('-a|');
      final actual = input.lift(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('--(a|)'));
    });
    test('throws error', () {
      final input = scheduler.cold<String>('-a#');
      final actual = input.lift(debounce(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable<String>('--#'));
    });
  });
  group('default_if_empty', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(defaultIfEmpty('x'));
      expect(actual, scheduler.isObservable('--(x|)'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(defaultIfEmpty('x'));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(defaultIfEmpty('x'));
      expect(actual, scheduler.isObservable('--a--b--c--|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(defaultIfEmpty('x'));
      expect(actual, scheduler.isObservable('--a--b--c--#'));
    });
  });
  group('delay', () {
    test('moderate delay', () {
      final input = scheduler.cold('-a-b--c---d----|');
      final actual = input.lift(delay(delay: scheduler.stepDuration * 2));
      expect(actual, scheduler.isObservable('---a-b--c---d----|'));
    });
    test('massive delay', () {
      final input = scheduler.cold('-a-b--c---d----|');
      final actual = input.lift(delay(delay: scheduler.stepDuration * 8));
      expect(actual, scheduler.isObservable('---------a-b--c---d----|'));
    });
    test('errors immediately', () {
      final input = scheduler.cold('-a-b--c---#');
      final actual = input.lift(delay(delay: scheduler.stepDuration * 4));
      expect(actual, scheduler.isObservable('-----a-b--#'));
    });
  });
  group('dematerialize', () {
    final values = <String, Event<String>>{
      'a': const NextEvent('a'),
      'b': const NextEvent('b'),
      'c': const CompleteEvent(),
      'e': const ErrorEvent('Error'),
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
    test('error in equals', () {
      final input = scheduler.cold<String>('-a-b-c-|');
      final actual = input
          .lift(distinct(equals: (a, b) => throw 'Error', hashCode: (a) => 0));
      expect(actual, scheduler.isObservable<String>('-a-#'));
    });
    test('error in hash', () {
      final input = scheduler.cold<String>('-a-b-c-|');
      final actual = input.lift(distinct(hashCode: (a) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
  });
  group('distinctUntilChanged', () {
    test('all unique values', () {
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.lift(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b-c-|'));
    });
    test('continuous repeats', () {
      final input = scheduler.cold('-a-bb-ccc-|');
      final actual = input.lift(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b--c---|'));
    });
    test('long repeats', () {
      final input = scheduler.cold('-(aaaaaaaaa)-(bbbbbbbbbbb)-|');
      final actual = input.lift(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b-|'));
    });
    test('overlapping repeats', () {
      final input = scheduler.cold('-a-b-a-b-|');
      final actual = input.lift(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b-a-b-|'));
    });
    test('coustom key', () {
      final input = scheduler.cold('-a-b-a-b-|');
      final actual = input.lift(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b-a-b-|'));
    });
    test('complete with error', () {
      final input = scheduler.cold('-a-bb-ccc-#');
      final actual = input.lift(distinctUntilChanged());
      expect(actual, scheduler.isObservable('-a-b--c---#'));
    });
    test('custom comparison', () {
      final input = scheduler.cold<String>('-(aAaA)-(BbBb)-|');
      final actual = input.lift(distinctUntilChanged<String, String>(
          compare: (a, b) => a.toLowerCase() == b.toLowerCase()));
      expect(actual, scheduler.isObservable<String>('-a-B-|'));
    });
    test('custom comparison throws', () {
      final input = scheduler.cold<String>('-aa-|');
      final actual = input.lift(distinctUntilChanged<String, String>(
          compare: (a, b) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-a#'));
    });
    test('custom key', () {
      final input = scheduler.cold<String>('-(aAaA)-(BbBb)-|');
      final actual = input.lift(
          distinctUntilChanged<String, String>(key: (a) => a.toLowerCase()));
      expect(actual, scheduler.isObservable<String>('-a-B-|'));
    });
    test('custom key throws', () {
      final input = scheduler.cold<String>('-aa-|');
      final actual = input.lift(
          distinctUntilChanged<String, String>(key: (a) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
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
    test('filter throws an error', () {
      final input = scheduler.cold('--a--b--#');
      final actual = input.lift(filter((value) => throw 'Error'));
      expect(actual, scheduler.isObservable('--#'));
    });
  });
  group('finalize', () {
    test('calls finalizer on completion', () {
      final input = scheduler.cold('-a--b-|');
      var seen = false;
      final actual = input.lift(finalize(() => seen = true));
      expect(seen, isFalse);
      expect(actual, scheduler.isObservable('-a--b-|'));
      expect(seen, isTrue);
    });
    test('calls finalizer on error', () {
      final input = scheduler.cold('-a--b-#');
      var seen = false;
      final actual = input.lift(finalize(() => seen = true));
      expect(seen, isFalse);
      expect(actual, scheduler.isObservable('-a--b-#'));
      expect(seen, isTrue);
    });
  });
  group('first', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(first());
      expect(actual, scheduler.isObservable('--#', error: TooFewError()));
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
  group('firstOrElse', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(firstOrElse(() => 'x'));
      expect(actual, scheduler.isObservable('--(x|)'));
    });
    test('no value and completion error', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(firstOrElse(() => throw ArgumentError()));
      expect(actual, scheduler.isObservable('--#', error: ArgumentError()));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(firstOrElse(() => fail('Not called')));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(firstOrElse(() => fail('Not called')));
      expect(actual, scheduler.isObservable('--(a|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(firstOrElse(() => fail('Not called')));
      expect(actual, scheduler.isObservable('--(a|)'));
    });
  });
  group('ignoreElements', () {
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(ignoreElements());
      expect(actual, scheduler.isObservable('-----------|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(ignoreElements());
      expect(actual, scheduler.isObservable('-----------#'));
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
      expect(actual, scheduler.isObservable('--#', error: TooFewError()));
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
  group('lastOrElse', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(lastOrElse(() => 'x'));
      expect(actual, scheduler.isObservable('--(x|)'));
    });
    test('no value and completion error', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(lastOrElse(() => throw ArgumentError()));
      expect(actual, scheduler.isObservable('--#', error: ArgumentError()));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.lift(lastOrElse(() => fail('Not called')));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.lift(lastOrElse(() => fail('Not called')));
      expect(actual, scheduler.isObservable('-----------(c|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.lift(lastOrElse(() => fail('Not called')));
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
    test('mapper throws error', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.lift(map<String, String>((value) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('--#'));
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
    final values = <String, Event<String>>{
      'a': const NextEvent('a'),
      'b': const NextEvent('b'),
      'c': const CompleteEvent(),
      'e': const ErrorEvent('Error'),
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
  group('mergeMap', () {
    test('inner with dynamic outputs', () {
      final actual = scheduler.cold<String>('-a--b---c---a--|', values: {
        'a': 'x-|',
        'b': 'yy-|',
        'c': 'zzz-|',
      }).lift(mergeMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x--yy--zzz-x--|'));
    });
    test('inner with error', () {
      final actual = scheduler.cold<String>('-a--b---c---a--|', values: {
        'a': 'x-|',
        'b': 'yy-|',
        'c': 'zz#',
      }).lift(mergeMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('outer with error', () {
      final actual = scheduler.cold<String>('-a--b---c-#', values: {
        'a': 'x-|',
        'b': 'yy-|',
        'c': 'zz#',
      }).lift(mergeMap((inner) => scheduler.cold<String>(inner)));
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('limit concurrent', () {
      final actual = scheduler.cold<String>('abc|', values: {
        'a': 'x---|',
        'b': 'y---|',
        'c': 'z---|',
      }).lift(
          mergeMap((inner) => scheduler.cold<String>(inner), concurrent: 2));
      expect(actual, scheduler.isObservable<String>('xy--z---|'));
    });
  });
  group('mergeMapTo', () {
    test('inner emits a single value', () {
      final inner = just('x');
      final actual =
          scheduler.cold<String>('-a--a---a-|').lift(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x--x---x-|'));
    });
    test('inner emits two values', () {
      final inner = scheduler.cold<String>('x-y-|');
      final actual =
          scheduler.cold<String>('-a--a---a-|').lift(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x-yx-y-x-y-|'));
    });
    test('inner started concurrently', () {
      final inner = scheduler.cold<String>('x-y-|');
      final actual = scheduler.cold<String>('-(ab)--|').lift(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-(xx)-(yy)-|'));
    });
    test('inner started overlappingly', () {
      final inner = scheduler.cold<String>('x-y-|');
      final actual = scheduler.cold<String>('-ab-|').lift(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-xxyy-|'));
    });
    test('inner throws', () {
      final inner = scheduler.cold<String>('x---#');
      final actual = scheduler.cold<String>('-a-b-|').lift(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x-x-#'));
    });
    test('outer throws', () {
      final inner = scheduler.cold<String>('x-y-z-|');
      final actual = scheduler.cold<String>('-a--#').lift(mergeMapTo(inner));
      expect(actual, scheduler.isObservable<String>('-x-y#'));
    });
    test('limit concurrent', () {
      final inner = scheduler.cold<String>('xyz|');
      final actual = scheduler
          .cold<String>('a---b---|')
          .lift(mergeMapTo(inner, concurrent: 1));
      expect(actual, scheduler.isObservable<String>('xyz-xyz-|'));
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
      test('error in computation', () {
        final input = scheduler.cold<String>('-a-b-c-|');
        final actual =
            input.lift(reduce<String>((previous, value) => throw 'Error'));
        expect(actual, scheduler.isObservable<String>('-a-#'));
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
      test('error in computation', () {
        final input = scheduler.cold<String>('-a-b-c-|');
        final actual =
            input.lift(fold('x', (previous, value) => throw 'Error'));
        expect(actual, scheduler.isObservable<String>('-#'));
      });
    });
  });
  group('single', () {
    test('no elements', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(single());
      expect(actual, scheduler.isObservable('--#', error: TooFewError()));
    });
    test('one element', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(single());
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('two elements', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.lift(single());
      expect(actual, scheduler.isObservable('-----#', error: TooManyError()));
    });
  });
  group('singleOrDefault', () {
    test('no elements', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(singleOrDefault(tooFew: 'f', tooMany: 'm'));
      expect(actual, scheduler.isObservable('--(f|)'));
    });
    test('one element', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(singleOrDefault(tooFew: 'f', tooMany: 'm'));
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('two elements', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.lift(singleOrDefault(tooFew: 'f', tooMany: 'm'));
      expect(actual, scheduler.isObservable('-----(m|)'));
    });
  });
  group('singleOrElse', () {
    final tooFew = StateError('Few');
    final tooMany = StateError('Many');
    test('no elements', () {
      final input = scheduler.cold('--|');
      final actual = input.lift(singleOrElse(
          tooFew: () => throw tooFew, tooMany: () => throw tooMany));
      expect(actual, scheduler.isObservable('--#', error: tooFew));
    });
    test('one element', () {
      final input = scheduler.cold('--a--|');
      final actual = input.lift(singleOrElse(
          tooFew: () => throw tooFew, tooMany: () => throw tooMany));
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('two elements', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.lift(singleOrElse(
          tooFew: () => throw tooFew, tooMany: () => throw tooMany));
      expect(actual, scheduler.isObservable('-----#', error: tooMany));
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
    test('predicate throws error', () {
      final input = scheduler.cold<String>('-a-|');
      final actual = input.lift(skipWhile((value) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
  });
  group('switchMap', () {
    final observables = {
      '1': scheduler.cold<String>('x|'),
      '2': scheduler.cold<String>('xy|'),
      '3': scheduler.cold<String>('xyz|'),
      '4': scheduler.cold<String>('xyz#'),
    };
    test('outer longer', () {
      final input = scheduler.cold('-1---2---3---|', values: observables);
      final actual = input.lift(switchMap((observable) => observable));
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz-|'));
    });
    test('inner longer', () {
      final input = scheduler.cold('-1---2---3|', values: observables);
      final actual = input.lift(switchMap((observable) => observable));
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz|'));
    });
    test('outer error', () {
      final input = scheduler.cold('-3#', values: observables);
      final actual = input.lift(switchMap((observable) => observable));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('inner error', () {
      final input = scheduler.cold('-4--4---4---|', values: observables);
      final actual = input.lift(switchMap((observable) => observable));
      expect(actual, scheduler.isObservable<String>('-xyzxyz#'));
    });
    test('project error', () {
      final input = scheduler.cold('-123-|');
      final actual = input.lift(switchMap((observable) => throw 'Error'));
      expect(actual, scheduler.isObservable('-#'));
    });
    test('overlapping', () {
      final input = scheduler.cold('-3--3-33--|', values: observables);
      final actual = input.lift(switchMap((observable) => observable));
      expect(actual, scheduler.isObservable<String>('-xyzxyxxyz|'));
    });
  });
  group('switchMapTo', () {
    test('outer longer', () {
      final input = scheduler.cold('-a---a---a---|');
      final actual = input.lift(switchMapTo(scheduler.cold<String>('xyz|')));
      expect(actual, scheduler.isObservable<String>('-xyz-xyz-xyz-|'));
    });
    test('inner longer', () {
      final input = scheduler.cold('-a---a---a|');
      final actual = input.lift(switchMapTo(scheduler.cold<String>('xyz|')));
      expect(actual, scheduler.isObservable<String>('-xyz-xyz-xyz|'));
    });
    test('outer error', () {
      final input = scheduler.cold('-a#');
      final actual = input.lift(switchMapTo(scheduler.cold<String>('xyz|')));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('inner error', () {
      final input = scheduler.cold('-a--a---a---|');
      final actual = input.lift(switchMapTo(scheduler.cold<String>('xyz#')));
      expect(actual, scheduler.isObservable<String>('-xyzxyz#'));
    });
    test('overlapping', () {
      final input = scheduler.cold('-a--a-aa--|');
      final actual = input.lift(switchMapTo(scheduler.cold<String>('xyz|')));
      expect(actual, scheduler.isObservable<String>('-xyzxyxxyz|'));
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
    test('predicate throws error', () {
      final input = scheduler.cold<String>('-a-|');
      final actual = input.lift(takeWhile((value) => throw 'Error'));
      expect(actual, scheduler.isObservable<String>('-#'));
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
