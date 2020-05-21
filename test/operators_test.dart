library rx.test.operators_test;

import 'package:more/collection.dart';
import 'package:rx/constructors.dart';
import 'package:rx/converters.dart';
import 'package:rx/core.dart';
import 'package:rx/operators.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/subjects.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart';

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
      final actual = input.buffer();
      expect(
          actual,
          scheduler.isObservable('-------(x|)', values: {
            'x': ['a', 'b', 'c']
          }));
    });
    test('max length', () {
      final input = scheduler.cold<String>('-a-b-c-d-e-|');
      final actual = input.buffer(maxLength: 2);
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
      final actual = input.buffer(maxAge: scheduler.stepDuration * 4);
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
          input.buffer(maxLength: 3, maxAge: scheduler.stepDuration * 4);
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
      final actual = input.buffer(trigger: scheduler.cold('--*--|'));
      expect(
          actual,
          scheduler.isObservable('--x-----(y|)', values: {
            'x': ['a', 'b'],
            'y': ['c', 'd', 'e', 'f', 'g', 'h'],
          }));
    });
    test('trigger is longer', () {
      final input = scheduler.cold<String>('abcdefgh|');
      final actual = input.buffer(trigger: scheduler.cold('--*--*--*--*--|'));
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
      final actual = input.buffer();
      expect(actual, scheduler.isObservable<List<String>>('---#'));
    });
    test('error in trigger', () {
      final input = scheduler.cold<String>('-a-b-|');
      final actual = input.buffer(trigger: scheduler.cold('--#'));
      expect(actual, scheduler.isObservable<List<String>>('--#'));
    });
  });
  group('cast', () {
    test('completes', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.cast<String>();
      expect(actual, scheduler.isObservable<String>('--a--b--c--|'));
    });
    test('error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.cast<String>();
      expect(actual, scheduler.isObservable<String>('--a--b--c--#'));
    });
  });
  group('catchError', () {
    test('silent', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.catchError(
          (error, [stackTrace]) => fail('Not supposed to be called'));
      expect(actual, scheduler.isObservable('--a--b--c--|'));
    });
    test('completes', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input.catchError((error, [stackTrace]) {
        expect(error, 'A');
        return null;
      });
      expect(actual, scheduler.isObservable('--a--b--c--|'));
    });
    test('throws different exception', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input.catchError((error, [stackTrace]) => throw 'B');
      expect(actual, scheduler.isObservable('--a--b--c--#', error: 'B'));
    });
    test('produces alternate observable', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input
          .catchError((error, [stackTrace]) => scheduler.cold('1--2--3--|'));
      expect(actual, scheduler.isObservable('--a--b--c--1--2--3--|'));
    });
    test('produces alternate observable that throws', () {
      final input = scheduler.cold('--a--b--c--#', error: 'A');
      final actual = input.catchError(
          (error, [stackTrace]) => scheduler.cold('1--#', error: 'B'));
      expect(actual, scheduler.isObservable('--a--b--c--1--#', error: 'B'));
    });
  });
  group('compose', () {
    Transformer<dynamic, T> mapper<T>(T ignore, T value) => (observable) =>
        observable.where((each) => each != ignore).mapTo<T>(value);
    test('basic', () {
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.compose(mapper('a', 'a'));
      expect(actual, scheduler.isObservable<String>('---a-a-|'));
    });
  });
  group('concat', () {
    group('beginWith', () {
      test('single value', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.beginWith(just('x'));
        expect(actual, scheduler.isObservable<String>('(xa)bc|'));
      });
      test('multiple values', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.beginWith(['x', 'y', 'z'].toObservable());
        expect(actual, scheduler.isObservable<String>('(xyza)bc|'));
      });
      test('observable', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.beginWith(scheduler.cold<String>('xyz|'));
        expect(actual, scheduler.isObservable<String>('xyzabc|'));
      });
      test('error', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.beginWith(throwError<String>('Error'));
        expect(actual, scheduler.isObservable<String>('#', error: 'Error'));
      });
    });
    group('endWith', () {
      test('single value', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.endWith(just('x'));
        expect(actual, scheduler.isObservable<String>('abc(x|)'));
      });
      test('multiple values', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.endWith(['x', 'y', 'z'].toObservable());
        expect(actual, scheduler.isObservable<String>('abc(xyz|)'));
      });
      test('observable', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.endWith(scheduler.cold<String>('xyz|'));
        expect(actual, scheduler.isObservable<String>('abcxyz|'));
      });
      test('error', () {
        final input = scheduler.cold<String>('abc|');
        final actual = input.endWith(throwError<String>('Error'));
        expect(actual, scheduler.isObservable<String>('abc#', error: 'Error'));
      });
    });
  });
  group('count', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.count();
      expect(actual, scheduler.isObservable('--(x|)', values: {'x': 0}));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.count();
      expect(actual, scheduler.isObservable<int>('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.count();
      expect(
          actual, scheduler.isObservable('-----------(x|)', values: {'x': 3}));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.count();
      expect(actual, scheduler.isObservable<int>('-----------#'));
    });
  });
  group('debounce', () {
    test('together', () {
      final input = scheduler.cold<String>('-ab----|');
      final actual = input.debounce(delay: scheduler.stepDuration * 2);
      expect(actual, scheduler.isObservable<String>('----b--|'));
    });
    test('separate', () {
      final input = scheduler.cold<String>('-a-b---|');
      final actual = input.debounce(delay: scheduler.stepDuration * 2);
      expect(actual, scheduler.isObservable<String>('-----b-|'));
    });
    test('split', () {
      final input = scheduler.cold<String>('-a--b--|');
      final actual = input.debounce(delay: scheduler.stepDuration * 2);
      expect(actual, scheduler.isObservable<String>('---a--b|'));
    });
    test('end early', () {
      final input = scheduler.cold<String>('-a|');
      final actual = input.debounce(delay: scheduler.stepDuration * 2);
      expect(actual, scheduler.isObservable<String>('--(a|)'));
    });
    test('throws error', () {
      final input = scheduler.cold<String>('-a#');
      final actual = input.debounce(delay: scheduler.stepDuration * 2);
      expect(actual, scheduler.isObservable<String>('--#'));
    });
  });
  group('defaultIfEmpty', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.defaultIfEmpty('x');
      expect(actual, scheduler.isObservable('--(x|)'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.defaultIfEmpty('x');
      expect(actual, scheduler.isObservable('--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.defaultIfEmpty('x');
      expect(actual, scheduler.isObservable('--a--b--c--|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.defaultIfEmpty('x');
      expect(actual, scheduler.isObservable('--a--b--c--#'));
    });
  });
  group('delay', () {
    test('moderate delay', () {
      final input = scheduler.cold('-a-b--c---d----|');
      final actual = input.delay(scheduler.stepDuration * 2);
      expect(actual, scheduler.isObservable('---a-b--c---d----|'));
    });
    test('massive delay', () {
      final input = scheduler.cold('-a-b--c---d----|');
      final actual = input.delay(scheduler.stepDuration * 8);
      expect(actual, scheduler.isObservable('---------a-b--c---d----|'));
    });
    test('errors immediately', () {
      final input = scheduler.cold('-a-b--c---#');
      final actual = input.delay(scheduler.stepDuration * 4);
      expect(actual, scheduler.isObservable('-----a-b--#'));
    });
  });
  group('dematerialize', () {
    final values = <String, Event<String>>{
      'a': Event.next('a'),
      'b': Event.next('b'),
      'c': Event.complete(),
      'e': Event.error('Error'),
      'f': TestEvent(0, Event.next('a')),
    };
    test('empty sequence', () {
      final input = scheduler.cold('-|', values: values);
      final actual = input.dematerialize();
      expect(actual, scheduler.isObservable<String>('-|'));
    });
    test('error sequence', () {
      final input = scheduler.cold('-a-#', values: values);
      final actual = input.dematerialize();
      expect(actual, scheduler.isObservable<String>('-a-#'));
    });
    test('values and completion', () {
      final input = scheduler.cold('-a--b---c-|', values: values);
      final actual = input.dematerialize();
      expect(actual, scheduler.isObservable<String>('-a--b---|'));
    });
    test('values and error', () {
      final input = scheduler.cold('-a--b---e-|', values: values);
      final actual = input.dematerialize();
      expect(actual, scheduler.isObservable<String>('-a--b---#'));
    });
    test('invalid event', () {
      final input = scheduler.cold('-a--b---f-|', values: values);
      final actual = input.dematerialize();
      expect(
          actual,
          scheduler.isObservable<String>('-a--b---#',
              error: UnexpectedEventError(values['f'])));
    });
  });
  group('distinct', () {
    test('all unique values', () {
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.distinct();
      expect(actual, scheduler.isObservable('-a-b-c-|'));
    });
    test('continuous repeats', () {
      final input = scheduler.cold('-a-bb-ccc-|');
      final actual = input.distinct();
      expect(actual, scheduler.isObservable('-a-b--c---|'));
    });
    test('overlapping repeats', () {
      final input = scheduler.cold('-a-ab-abc-#');
      final actual = input.distinct();
      expect(actual, scheduler.isObservable('-a--b---c-#'));
    });
    test('error in equals', () {
      final input = scheduler.cold<String>('-a-b-c-|');
      final actual =
          input.distinct(equals: (a, b) => throw 'Error', hashCode: (a) => 0);
      expect(actual, scheduler.isObservable<String>('-a-#'));
    });
    test('error in hash', () {
      final input = scheduler.cold<String>('-a-b-c-|');
      final actual = input.distinct(hashCode: (a) => throw 'Error');
      expect(actual, scheduler.isObservable<String>('-#'));
    });
  });
  group('distinctUntilChanged', () {
    test('all unique values', () {
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.distinctUntilChanged();
      expect(actual, scheduler.isObservable('-a-b-c-|'));
    });
    test('continuous repeats', () {
      final input = scheduler.cold('-a-bb-ccc-|');
      final actual = input.distinctUntilChanged();
      expect(actual, scheduler.isObservable('-a-b--c---|'));
    });
    test('long repeats', () {
      final input = scheduler.cold('-(aaaaaaaaa)-(bbbbbbbbbbb)-|');
      final actual = input.distinctUntilChanged();
      expect(actual, scheduler.isObservable('-a-b-|'));
    });
    test('overlapping repeats', () {
      final input = scheduler.cold('-a-b-a-b-|');
      final actual = input.distinctUntilChanged();
      expect(actual, scheduler.isObservable('-a-b-a-b-|'));
    });
    test('coustom key', () {
      final input = scheduler.cold('-a-b-a-b-|');
      final actual = input.distinctUntilChanged();
      expect(actual, scheduler.isObservable('-a-b-a-b-|'));
    });
    test('complete with error', () {
      final input = scheduler.cold('-a-bb-ccc-#');
      final actual = input.distinctUntilChanged();
      expect(actual, scheduler.isObservable('-a-b--c---#'));
    });
    test('custom comparison', () {
      final input = scheduler.cold<String>('-(aAaA)-(BbBb)-|');
      final actual = input.distinctUntilChanged(
          compare: (a, b) => a.toLowerCase() == b.toLowerCase());
      expect(actual, scheduler.isObservable<String>('-a-B-|'));
    });
    test('custom comparison throws', () {
      final input = scheduler.cold<String>('-aa-|');
      final actual =
          input.distinctUntilChanged(compare: (a, b) => throw 'Error');
      expect(actual, scheduler.isObservable<String>('-a#'));
    });
    test('custom key', () {
      final input = scheduler.cold<String>('-(aAaA)-(BbBb)-|');
      final actual = input.distinctUntilChanged(key: (a) => a.toLowerCase());
      expect(actual, scheduler.isObservable<String>('-a-B-|'));
    });
    test('custom key throws', () {
      final input = scheduler.cold<String>('-aa-|');
      final actual = input.distinctUntilChanged(key: (a) => throw 'Error');
      expect(actual, scheduler.isObservable<String>('-#'));
    });
  });
  group('exhaustAll', () {
    test('inner is shorter', () {
      final actual = scheduler.cold('-a--b--c--|', values: {
        'a': scheduler.cold<String>('x|'),
        'b': scheduler.cold<String>('y|'),
        'c': scheduler.cold<String>('z|'),
      }).exhaustAll();
      expect(actual, scheduler.isObservable<String>('-x--y--z--|'));
    });
    test('outer is shorter', () {
      final actual = scheduler.cold('-a--b--c|', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('y-|'),
        'c': scheduler.cold<String>('z-|'),
      }).exhaustAll();
      expect(actual, scheduler.isObservable<String>('-x--y--z-|'));
    });
    test('inner throws', () {
      final actual = scheduler.cold('-a--b--|', values: {
        'a': scheduler.cold<String>('x#'),
        'b': scheduler.cold<String>('y-|'),
      }).exhaustAll();
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('outer throws', () {
      final actual = scheduler.cold('-a#-b--|', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('y-|'),
      }).exhaustAll();
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('overlapping', () {
      final actual = scheduler.cold('-a-b---ba-|', values: {
        'a': scheduler.cold<String>('1-2-3|'),
        'b': scheduler.cold<String>('45|'),
      }).exhaustAll();
      expect(actual, scheduler.isObservable<String>('-1-2-3-45-|'));
    });
    test('limit concurrent', () {
      final actual = scheduler.cold('abc|', values: {
        'a': scheduler.cold<String>('x---|'),
        'b': scheduler.cold<String>('y---|'),
        'c': scheduler.cold<String>('z---|'),
      }).exhaustAll(concurrent: 2);
      expect(actual, scheduler.isObservable<String>('xy---|'));
    });
    test('invalid concurrent', () {
      expect(() => never<Observable<void>>().exhaustAll(concurrent: 0),
          throwsRangeError);
    });
  });
  group('exhaustMap', () {
    test('inner is shorter', () {
      final actual = scheduler.cold('-a--b--c--|', values: {
        'a': 'x|',
        'b': 'y|',
        'c': 'z|',
      }).exhaustMap((inner) => scheduler.cold<String>(inner));
      expect(actual, scheduler.isObservable<String>('-x--y--z--|'));
    });
    test('outer is shorter', () {
      final actual = scheduler.cold('-a--b--c|', values: {
        'a': 'x-|',
        'b': 'y-|',
        'c': 'z-|',
      }).exhaustMap((inner) => scheduler.cold<String>(inner));
      expect(actual, scheduler.isObservable<String>('-x--y--z-|'));
    });
    test('projection throws', () {
      final actual =
          scheduler.cold('-a-b-|').exhaustMap<String>((inner) => throw 'Error');
      expect(actual, scheduler.isObservable<String>('-#'));
    });
    test('inner throws', () {
      final actual = scheduler.cold('-a--b--|', values: {
        'a': 'x#',
        'b': 'y-|'
      }).exhaustMap((inner) => scheduler.cold<String>(inner));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('outer throws', () {
      final actual = scheduler.cold('-a#-b--|', values: {
        'a': 'x-|',
        'b': 'y-|',
      }).exhaustMap((inner) => scheduler.cold<String>(inner));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('overlapping', () {
      final actual = scheduler.cold('-a-b---ba-|', values: {
        'a': '1-2-3|',
        'b': '45|',
      }).exhaustMap((inner) => scheduler.cold<String>(inner));
      expect(actual, scheduler.isObservable<String>('-1-2-3-45-|'));
    });
    test('limit concurrent', () {
      final actual = scheduler.cold('abc|', values: {
        'a': 'x---|',
        'b': 'y---|',
        'c': 'z---|',
      }).exhaustMap((inner) => scheduler.cold<String>(inner), concurrent: 2);
      expect(actual, scheduler.isObservable<String>('xy---|'));
    });
    test('invalid concurrent', () {
      expect(
          () => never().exhaustMap((inner) => scheduler.cold<String>(inner),
              concurrent: 0),
          throwsRangeError);
    });
  });
  group('exhaustMapTo', () {
    test('inner is shorter', () {
      final inner = scheduler.cold<String>('x|');
      final actual = scheduler.cold('-a--b--c--|').exhaustMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-x--x--x--|'));
    });
    test('outer is shorter', () {
      final inner = scheduler.cold<String>('x-|');
      final actual = scheduler.cold('-a--b--c|').exhaustMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-x--x--x-|'));
    });
    test('inner throws', () {
      final inner = scheduler.cold<String>('x#');
      final actual = scheduler.cold('-a--b--|').exhaustMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('outer throws', () {
      final inner = scheduler.cold<String>('x-|');
      final actual = scheduler.cold('-a#-b--|').exhaustMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('overlapping', () {
      final inner = scheduler.cold<String>('1-2-3|');
      final actual = scheduler.cold('-a-b---ba-|').exhaustMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-1-2-3-1-2-3|'));
    });
    test('limit concurrent', () {
      final inner = scheduler.cold<String>('x---|');
      final actual = scheduler.cold('abc|').exhaustMapTo(inner, concurrent: 2);
      expect(actual, scheduler.isObservable<String>('xx---|'));
    });
    test('invalid concurrent', () {
      expect(
          () => never().exhaustMapTo(scheduler.cold<String>(''), concurrent: 0),
          throwsRangeError);
    });
  });
  group('finalize', () {
    test('calls finalizer on completion', () {
      final input = scheduler.cold('-a--b-|');
      var seen = false;
      final actual = input.finalize(() => seen = true);
      expect(seen, isFalse);
      expect(actual, scheduler.isObservable('-a--b-|'));
      expect(seen, isTrue);
    });
    test('calls finalizer on error', () {
      final input = scheduler.cold('-a--b-#');
      var seen = false;
      final actual = input.finalize(() => seen = true);
      expect(seen, isFalse);
      expect(actual, scheduler.isObservable('-a--b-#'));
      expect(seen, isTrue);
    });
  });
  group('first', () {
    group('first', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.first();
        expect(actual, scheduler.isObservable('--#', error: TooFewError()));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.first();
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.first();
        expect(actual, scheduler.isObservable('--(a|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.first();
        expect(actual, scheduler.isObservable('--(a|)'));
      });
    });
    group('firstOrDefault', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.firstOrDefault('x');
        expect(actual, scheduler.isObservable('--(x|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.firstOrDefault('x');
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.firstOrDefault('x');
        expect(actual, scheduler.isObservable('--(a|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.firstOrDefault('x');
        expect(actual, scheduler.isObservable('--(a|)'));
      });
    });
    group('firstOrElse', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.firstOrElse(() => 'x');
        expect(actual, scheduler.isObservable('--(x|)'));
      });
      test('no value and completion error', () {
        final input = scheduler.cold('--|');
        final actual = input.firstOrElse(() => throw ArgumentError());
        expect(actual, scheduler.isObservable('--#', error: ArgumentError()));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.firstOrElse(() => fail('Not called'));
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.firstOrElse(() => fail('Not called'));
        expect(actual, scheduler.isObservable('--(a|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.firstOrElse(() => fail('Not called'));
        expect(actual, scheduler.isObservable('--(a|)'));
      });
    });
    group('findFirst', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.findFirst(predicate);
        expect(actual,
            scheduler.isObservable<String>('--#', error: TooFewError()));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.findFirst(predicate);
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.findFirst(predicate);
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.findFirst(predicate);
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.findFirst(predicate);
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
    group('findFirstOrDefault', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.findFirstOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('--(y|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.findFirstOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.findFirstOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.findFirstOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.findFirstOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
    group('findFirstOrElse', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.findFirstOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('--(y|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.findFirstOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('no value and completion error', () {
        final input = scheduler.cold<String>('--|');
        final actual =
            input.findFirstOrElse(predicate, () => throw ArgumentError());
        expect(actual,
            scheduler.isObservable<String>('--#', error: ArgumentError()));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.findFirstOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.findFirstOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('-----(B|)'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.findFirstOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
  });
  group('flatMap', () {
    group('flatten', () {
      test('inner with dynamic outputs', () {
        final actual = scheduler.cold('-a--b---c---a--|', values: {
          'a': scheduler.cold<String>('x-|'),
          'b': scheduler.cold<String>('yy-|'),
          'c': scheduler.cold<String>('zzz-|'),
        }).flatten();
        expect(actual, scheduler.isObservable<String>('-x--yy--zzz-x--|'));
      });
      test('inner with error', () {
        final actual = scheduler.cold('-a--b---c---a--|', values: {
          'a': scheduler.cold<String>('x-|'),
          'b': scheduler.cold<String>('yy-|'),
          'c': scheduler.cold<String>('zz#'),
        }).flatten();
        expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
      });
      test('outer with error', () {
        final actual = scheduler.cold('-a--b---c-#', values: {
          'a': scheduler.cold<String>('x-|'),
          'b': scheduler.cold<String>('yy-|'),
          'c': scheduler.cold<String>('zz#'),
        }).flatten();
        expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
      });
      test('limit concurrent', () {
        final actual = scheduler.cold('abc|', values: {
          'a': scheduler.cold<String>('x---|'),
          'b': scheduler.cold<String>('y---|'),
          'c': scheduler.cold<String>('z---|'),
        }).flatten(concurrent: 2);
        expect(actual, scheduler.isObservable<String>('xy--z---|'));
      });
      test('invalid concurrent', () {
        expect(() => never<Observable<String>>().flatten(concurrent: 0),
            throwsRangeError);
      });
    });
    group('flatMap', () {
      test('inner with dynamic outputs', () {
        final actual = scheduler.cold<String>('-a--b---c---a--|', values: {
          'a': 'x-|',
          'b': 'yy-|',
          'c': 'zzz-|',
        }).flatMap((inner) => scheduler.cold<String>(inner));
        expect(actual, scheduler.isObservable<String>('-x--yy--zzz-x--|'));
      });
      test('projection throws', () {
        final actual =
            scheduler.cold('-a-|').flatMap<String>((inner) => throw 'Error');
        expect(actual, scheduler.isObservable<String>('-#'));
      });
      test('inner with error', () {
        final actual = scheduler.cold('-a--b---c---a--|', values: {
          'a': 'x-|',
          'b': 'yy-|',
          'c': 'zz#',
        }).flatMap((inner) => scheduler.cold<String>(inner));
        expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
      });
      test('outer with error', () {
        final actual = scheduler.cold('-a--b---c-#', values: {
          'a': 'x-|',
          'b': 'yy-|',
          'c': 'zz#',
        }).flatMap((inner) => scheduler.cold<String>(inner));
        expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
      });
      test('limit concurrent', () {
        final actual = scheduler.cold('abc|', values: {
          'a': 'x---|',
          'b': 'y---|',
          'c': 'z---|',
        }).flatMap((inner) => scheduler.cold<String>(inner), concurrent: 2);
        expect(actual, scheduler.isObservable<String>('xy--z---|'));
      });
      test('invalid concurrent', () {
        expect(
            () => never().flatMap((inner) => scheduler.cold<String>(inner),
                concurrent: 0),
            throwsRangeError);
      });
    });
    group('flatMapTo', () {
      test('inner emits a single value', () {
        final inner = just('x');
        final actual = scheduler.cold('-a--a---a-|').flatMapTo(inner);
        expect(actual, scheduler.isObservable<String>('-x--x---x-|'));
      });
      test('inner emits two values', () {
        final inner = scheduler.cold<String>('x-y-|');
        final actual = scheduler.cold('-a--a---a-|').flatMapTo(inner);
        expect(actual, scheduler.isObservable<String>('-x-yx-y-x-y-|'));
      });
      test('inner started concurrently', () {
        final inner = scheduler.cold<String>('x-y-|');
        final actual = scheduler.cold('-(ab)--|').flatMapTo(inner);
        expect(actual, scheduler.isObservable<String>('-(xx)-(yy)-|'));
      });
      test('inner started overlappingly', () {
        final inner = scheduler.cold<String>('x-y-|');
        final actual = scheduler.cold('-ab-|').flatMapTo(inner);
        expect(actual, scheduler.isObservable<String>('-xxyy-|'));
      });
      test('inner throws', () {
        final inner = scheduler.cold<String>('x---#');
        final actual = scheduler.cold('-a-b-|').flatMapTo(inner);
        expect(actual, scheduler.isObservable<String>('-x-x-#'));
      });
      test('outer throws', () {
        final inner = scheduler.cold<String>('x-y-z-|');
        final actual = scheduler.cold('-a--#').flatMapTo(inner);
        expect(actual, scheduler.isObservable<String>('-x-y#'));
      });
      test('limit concurrent', () {
        final inner = scheduler.cold<String>('xyz|');
        final actual =
            scheduler.cold('a---b---|').flatMapTo(inner, concurrent: 1);
        expect(actual, scheduler.isObservable<String>('xyz-xyz-|'));
      });
      test('invalid concurrent', () {
        expect(() => never().flatMapTo(scheduler.cold(''), concurrent: 0),
            throwsRangeError);
      });
    });
  });
  group('ignoreElements', () {
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.ignoreElements();
      expect(actual, scheduler.isObservable('-----------|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.ignoreElements();
      expect(actual, scheduler.isObservable('-----------#'));
    });
  });
  group('isEmpty', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.isEmpty();
      expect(actual, scheduler.isObservable('--(t|)', values: boolMap));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.isEmpty();
      expect(actual, scheduler.isObservable('--#', values: boolMap));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.isEmpty();
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.isEmpty();
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.isEmpty();
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.isEmpty();
      expect(actual, scheduler.isObservable('--(f|)', values: boolMap));
    });
  });
  group('last', () {
    group('last', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.last();
        expect(actual, scheduler.isObservable('--#', error: TooFewError()));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.last();
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.last();
        expect(actual, scheduler.isObservable('-----------(c|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.last();
        expect(actual, scheduler.isObservable('-----------#'));
      });
    });
    group('lastOrDefault', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.lastOrDefault('x');
        expect(actual, scheduler.isObservable('--(x|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.lastOrDefault('x');
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.lastOrDefault('x');
        expect(actual, scheduler.isObservable('-----------(c|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.lastOrDefault('x');
        expect(actual, scheduler.isObservable('-----------#'));
      });
    });
    group('lastOrElse', () {
      test('no value and completion', () {
        final input = scheduler.cold('--|');
        final actual = input.lastOrElse(() => 'x');
        expect(actual, scheduler.isObservable('--(x|)'));
      });
      test('no value and completion error', () {
        final input = scheduler.cold('--|');
        final actual = input.lastOrElse(() => throw ArgumentError());
        expect(actual, scheduler.isObservable('--#', error: ArgumentError()));
      });
      test('no value and error', () {
        final input = scheduler.cold('--#');
        final actual = input.lastOrElse(() => fail('Not called'));
        expect(actual, scheduler.isObservable('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold('--a--b--c--|');
        final actual = input.lastOrElse(() => fail('Not called'));
        expect(actual, scheduler.isObservable('-----------(c|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold('--a--b--c--#');
        final actual = input.lastOrElse(() => fail('Not called'));
        expect(actual, scheduler.isObservable('-----------#'));
      });
    });
    group('findLast', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.findLast(predicate);
        expect(actual,
            scheduler.isObservable<String>('--#', error: TooFewError()));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.findLast(predicate);
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.findLast(predicate);
        expect(actual, scheduler.isObservable<String>('-----------(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.findLast(predicate);
        expect(actual, scheduler.isObservable<String>('-----------#'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.findLast(predicate);
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
    group('findLastOrDefault', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.findLastOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('--(y|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.findLastOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.findLastOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('-----------(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.findLastOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('-----------#'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.findLastOrDefault(predicate, 'y');
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
    group('findLastOrElse', () {
      test('no value and completion', () {
        final input = scheduler.cold<String>('--|');
        final actual = input.findLastOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('--(y|)'));
      });
      test('no value and error', () {
        final input = scheduler.cold<String>('--#');
        final actual = input.findLastOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('--#'));
      });
      test('no value and completion error', () {
        final input = scheduler.cold<String>('--|');
        final actual =
            input.findLastOrElse(predicate, () => throw ArgumentError());
        expect(actual,
            scheduler.isObservable<String>('--#', error: ArgumentError()));
      });
      test('multiple values and completion', () {
        final input = scheduler.cold<String>('--a--B--c--|');
        final actual = input.findLastOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('-----------(B|)'));
      });
      test('multiple values and error', () {
        final input = scheduler.cold<String>('--a--B--c--#');
        final actual = input.findLastOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('-----------#'));
      });
      test('multiple values and predicate error', () {
        final input = scheduler.cold<String>('--x--B--c--|');
        final actual = input.findLastOrElse(predicate, () => 'y');
        expect(actual, scheduler.isObservable<String>('--#'));
      });
    });
  });
  group('map', () {
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.map((value) => '$value!');
      expect(actual, scheduler.isObservable('--a--|', values: {'a': 'a!'}));
    });
    test('single value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.map((value) => '$value!');
      expect(actual, scheduler.isObservable('--a--#', values: {'a': 'a!'}));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.map((value) => '$value!');
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': 'a!', 'b': 'b!', 'c': 'c!'}));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.map((value) => '$value!');
      expect(
          actual,
          scheduler.isObservable('--a--b--c--#',
              values: {'a': 'a!', 'b': 'b!', 'c': 'c!'}));
    });
    test('mapper throws error', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.map<String>((value) => throw 'Error');
      expect(actual, scheduler.isObservable<String>('--#'));
    });
  });
  group('mapTo', () {
    test('single value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.mapTo('x');
      expect(actual, scheduler.isObservable<String>('--x--|'));
    });
    test('single value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.mapTo('x');
      expect(actual, scheduler.isObservable<String>('--x--#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold('--a--b--c--|');
      final actual = input.mapTo('x');
      expect(actual, scheduler.isObservable<String>('--x--x--x--|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('--a--b--c--#');
      final actual = input.mapTo('x');
      expect(actual, scheduler.isObservable<String>('--x--x--x--#'));
    });
  });
  group('materialize', () {
    final values = <String, Event<String>>{
      'a': Event.next('a'),
      'b': Event.next('b'),
      'c': Event.complete(),
      'e': Event.error('Error'),
    };
    test('empty sequence', () {
      final input = scheduler.cold<String>('-|');
      final actual = input.materialize();
      expect(actual, scheduler.isObservable('-(c|)', values: values));
    });
    test('error sequence', () {
      final input = scheduler.cold<String>('-a-#');
      final actual = input.materialize();
      expect(actual, scheduler.isObservable('-a-(e|)', values: values));
    });
    test('values and completion', () {
      final input = scheduler.cold<String>('-a--b---|');
      final actual = input.materialize();
      expect(actual, scheduler.isObservable('-a--b---(c|)', values: values));
    });
    test('values and error', () {
      final input = scheduler.cold<String>('-a--b---#-|');
      final actual = input.materialize();
      expect(actual, scheduler.isObservable('-a--b---(e|)', values: values));
    });
  });
  group('mergeAll', () {
    test('inner with dynamic outputs', () {
      final actual = scheduler.cold('-a--b---c---a--|', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('yy-|'),
        'c': scheduler.cold<String>('zzz-|'),
      }).mergeAll();
      expect(actual, scheduler.isObservable<String>('-x--yy--zzz-x--|'));
    });
    test('inner with error', () {
      final actual = scheduler.cold('-a--b---c---a--|', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('yy-|'),
        'c': scheduler.cold<String>('zz#'),
      }).mergeAll();
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('outer with error', () {
      final actual = scheduler.cold('-a--b---c-#', values: {
        'a': scheduler.cold<String>('x-|'),
        'b': scheduler.cold<String>('yy-|'),
        'c': scheduler.cold<String>('zz#'),
      }).mergeAll();
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('limit concurrent', () {
      final actual = scheduler.cold('abc|', values: {
        'a': scheduler.cold<String>('x---|'),
        'b': scheduler.cold<String>('y---|'),
        'c': scheduler.cold<String>('z---|'),
      }).mergeAll(concurrent: 2);
      expect(actual, scheduler.isObservable<String>('xy--z---|'));
    });
    test('invalid concurrent', () {
      expect(() => never<Observable<String>>().mergeAll(concurrent: 0),
          throwsRangeError);
    });
  });
  group('mergeMap', () {
    test('inner with dynamic outputs', () {
      final actual = scheduler.cold<String>('-a--b---c---a--|', values: {
        'a': 'x-|',
        'b': 'yy-|',
        'c': 'zzz-|',
      }).mergeMap((inner) => scheduler.cold<String>(inner));
      expect(actual, scheduler.isObservable<String>('-x--yy--zzz-x--|'));
    });
    test('projection throws', () {
      final actual =
          scheduler.cold('-a-|').mergeMap<String>((inner) => throw 'Error');
      expect(actual, scheduler.isObservable<String>('-#'));
    });
    test('inner with error', () {
      final actual = scheduler.cold('-a--b---c---a--|', values: {
        'a': 'x-|',
        'b': 'yy-|',
        'c': 'zz#',
      }).mergeMap((inner) => scheduler.cold<String>(inner));
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('outer with error', () {
      final actual = scheduler.cold('-a--b---c-#', values: {
        'a': 'x-|',
        'b': 'yy-|',
        'c': 'zz#',
      }).mergeMap((inner) => scheduler.cold<String>(inner));
      expect(actual, scheduler.isObservable<String>('-x--yy--zz#'));
    });
    test('limit concurrent', () {
      final actual = scheduler.cold('abc|', values: {
        'a': 'x---|',
        'b': 'y---|',
        'c': 'z---|',
      }).mergeMap((inner) => scheduler.cold<String>(inner), concurrent: 2);
      expect(actual, scheduler.isObservable<String>('xy--z---|'));
    });
    test('invalid concurrent', () {
      expect(
          () => never().mergeMap((inner) => scheduler.cold<String>(inner),
              concurrent: 0),
          throwsRangeError);
    });
  });
  group('mergeMapTo', () {
    test('inner emits a single value', () {
      final inner = just('x');
      final actual = scheduler.cold('-a--a---a-|').mergeMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-x--x---x-|'));
    });
    test('inner emits two values', () {
      final inner = scheduler.cold<String>('x-y-|');
      final actual = scheduler.cold('-a--a---a-|').mergeMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-x-yx-y-x-y-|'));
    });
    test('inner started concurrently', () {
      final inner = scheduler.cold<String>('x-y-|');
      final actual = scheduler.cold('-(ab)--|').mergeMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-(xx)-(yy)-|'));
    });
    test('inner started overlappingly', () {
      final inner = scheduler.cold<String>('x-y-|');
      final actual = scheduler.cold('-ab-|').mergeMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-xxyy-|'));
    });
    test('inner throws', () {
      final inner = scheduler.cold<String>('x---#');
      final actual = scheduler.cold('-a-b-|').mergeMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-x-x-#'));
    });
    test('outer throws', () {
      final inner = scheduler.cold<String>('x-y-z-|');
      final actual = scheduler.cold('-a--#').mergeMapTo(inner);
      expect(actual, scheduler.isObservable<String>('-x-y#'));
    });
    test('limit concurrent', () {
      final inner = scheduler.cold<String>('xyz|');
      final actual =
          scheduler.cold('a---b---|').mergeMapTo(inner, concurrent: 1);
      expect(actual, scheduler.isObservable<String>('xyz-xyz-|'));
    });
    test('invalid concurrent', () {
      expect(() => never().mergeMapTo(scheduler.cold(''), concurrent: 0),
          throwsRangeError);
    });
  });
  group('multicast', () {
    test('argument error', () {
      expect(
          () => never().multicast(subject: Subject(), factory: () => Subject()),
          throwsArgumentError);
    });
    test('incomplete sequence', () {
      final source = scheduler.cold<String>('-a-b-c-');
      final actual = source.multicast();
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('-a-b-c-'));
      expect(actual, scheduler.isObservable<String>(''));
    });
    test('complete sequence', () {
      final source = scheduler.cold<String>('-a-b-c-|');
      final actual = source.multicast();
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('-a-b-c-|'));
      expect(actual, scheduler.isObservable<String>('|'));
    });
    test('error sequence', () {
      final source = scheduler.cold<String>('-a-b-c-#');
      final actual = source.multicast();
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('-a-b-c-#'));
      expect(actual, scheduler.isObservable<String>('#'));
    });
  });
  group('observeOn', () {
    test('plain sequence', () {
      final actual =
          scheduler.cold<String>('-a-b-c-|').observeOn(ImmediateScheduler());
      expect(actual, scheduler.isObservable<String>('-a-b-c-|'));
    });
    test('sequence with delay', () {
      final actual = scheduler
          .cold<String>('-a-b-c-|')
          .observeOn(scheduler, delay: scheduler.stepDuration);
      expect(actual, scheduler.isObservable<String>('--a-b-c-|'));
    });
    test('error sequence', () {
      final actual =
          scheduler.cold<String>('-a-b-c-#').observeOn(ImmediateScheduler());
      expect(actual, scheduler.isObservable<String>('-a-b-c-#'));
    });
    test('error with delay', () {
      final actual = scheduler
          .cold<String>('-a-b-c-#')
          .observeOn(scheduler, delay: scheduler.stepDuration);
      expect(actual, scheduler.isObservable<String>('--a-b-c-#'));
    });
  });
  group('publishBehavior', () {
    test('incomplete sequence', () {
      final source = scheduler.cold<String>('-a-b-c-');
      final actual = source.publishBehavior('x');
      expect(actual, scheduler.isObservable<String>('x'));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('xa-b-c-'));
      expect(actual, scheduler.isObservable<String>('c'));
    });
    test('complete sequence', () {
      final source = scheduler.cold<String>('-a-b-c-|');
      final actual = source.publishBehavior('x');
      expect(actual, scheduler.isObservable<String>('x'));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('xa-b-c-|'));
      expect(actual, scheduler.isObservable<String>('(c|)'));
    });
    test('error sequence', () {
      final source = scheduler.cold<String>('-a-b-c-#');
      final actual = source.publishBehavior('x');
      expect(actual, scheduler.isObservable<String>('x'));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('xa-b-c-#'));
      expect(actual, scheduler.isObservable<String>('#'));
    });
  });
  group('publishLast', () {
    test('incomplete sequence', () {
      final source = scheduler.cold<String>('-a-b-c-');
      final actual = source.publishLast();
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>(''));
      expect(actual, scheduler.isObservable<String>(''));
    });
    test('complete sequence', () {
      final source = scheduler.cold<String>('-a-b-c-|');
      final actual = source.publishLast();
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('-------(c|)'));
      expect(actual, scheduler.isObservable<String>('(c|)'));
    });
    test('error sequence', () {
      final source = scheduler.cold<String>('-a-b-c-#');
      final actual = source.publishLast();
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('-------#'));
      expect(actual, scheduler.isObservable<String>('#'));
    });
  });
  group('publishReplay', () {
    test('incomplete sequence', () {
      final source = scheduler.cold<String>('-a-b-c-');
      final actual = source.publishReplay();
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('-a-b-c-'));
      expect(actual, scheduler.isObservable<String>('(abc)'));
    });
    test('complete sequence', () {
      final source = scheduler.cold<String>('-a-b-c-|');
      final actual = source.publishReplay();
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('-a-b-c-|'));
      expect(actual, scheduler.isObservable<String>('(abc|)'));
    });
    test('error sequence', () {
      final source = scheduler.cold<String>('-a-b-c-#');
      final actual = source.publishReplay();
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('-a-b-c-#'));
      expect(actual, scheduler.isObservable<String>('#'));
    });
    test('size sequence', () {
      final source = scheduler.cold<String>('-a-b-c-');
      final actual = source.publishReplay(bufferSize: 2);
      expect(actual, scheduler.isObservable<String>(''));
      actual.connect();
      expect(actual, scheduler.isObservable<String>('-a-b-c-'));
      expect(actual, scheduler.isObservable<String>('(bc)'));
    });
  });
  group('refCount', () {});
  group('sample', () {
    test('samples on value trigger', () {
      final actual = scheduler
          .cold<String>('-a-b-c---d-|')
          .sample(scheduler.cold('--x---x-x-x--|'));
      expect(actual, scheduler.isObservable<String>('--a---c---d|'));
    });
    test('samples on completion of trigger', () {
      final actual = scheduler
          .cold<String>('-a-b-c---d-|')
          .sample(scheduler.cold('--x---x-x-|'));
      expect(actual, scheduler.isObservable<String>('--a---c---d|'));
    });
    test('input throws', () {
      final actual =
          scheduler.cold<String>('-#').sample(scheduler.cold('-x-|'));
      expect(actual, scheduler.isObservable<String>('-#'));
    });
    test('trigger throws', () {
      final actual =
          scheduler.cold<String>('-a-b-c---d-|').sample(scheduler.cold('--#'));
      expect(actual, scheduler.isObservable<String>('--#'));
    });
  });
  group('scan', () {
    group('reduce', () {
      test('values and completion', () {
        final input = scheduler.cold<String>('-a--b---c-|');
        final actual = input.reduce((previous, value) => '$previous$value');
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
        final actual = input.reduce((previous, value) => '$previous$value');
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
        final actual = input.reduce((previous, value) => throw 'Error');
        expect(actual, scheduler.isObservable<String>('-a-#'));
      });
    });
    group('fold', () {
      test('values and completion', () {
        final input = scheduler.cold<String>('-a--b---c-|');
        final actual = input.fold('x', (previous, value) => '$previous$value');
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
        final actual = input.fold('x', (previous, value) => '$previous$value');
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
        final actual = input.fold(
            <String>[], (previous, value) => <String>[...previous, value]);
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
        final actual = input.fold('x', (previous, value) => throw 'Error');
        expect(actual, scheduler.isObservable<String>('-#'));
      });
    });
  });
  group('single', () {
    test('no elements', () {
      final input = scheduler.cold('--|');
      final actual = input.single();
      expect(actual, scheduler.isObservable('--#', error: TooFewError()));
    });
    test('one element', () {
      final input = scheduler.cold('--a--|');
      final actual = input.single();
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('two elements', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.single();
      expect(actual, scheduler.isObservable('-----#', error: TooManyError()));
    });
  });
  group('singleOrDefault', () {
    test('no elements', () {
      final input = scheduler.cold('--|');
      final actual = input.singleOrDefault(tooFew: 'f', tooMany: 'm');
      expect(actual, scheduler.isObservable('--(f|)'));
    });
    test('one element', () {
      final input = scheduler.cold('--a--|');
      final actual = input.singleOrDefault(tooFew: 'f', tooMany: 'm');
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('two elements', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.singleOrDefault(tooFew: 'f', tooMany: 'm');
      expect(actual, scheduler.isObservable('-----(m|)'));
    });
  });
  group('singleOrElse', () {
    final tooFew = StateError('Few');
    final tooMany = StateError('Many');
    test('no elements', () {
      final input = scheduler.cold('--|');
      final actual = input.singleOrElse(
          tooFew: () => throw tooFew, tooMany: () => throw tooMany);
      expect(actual, scheduler.isObservable('--#', error: tooFew));
    });
    test('one element', () {
      final input = scheduler.cold('--a--|');
      final actual = input.singleOrElse(
          tooFew: () => throw tooFew, tooMany: () => throw tooMany);
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('two elements', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.singleOrElse(
          tooFew: () => throw tooFew, tooMany: () => throw tooMany);
      expect(actual, scheduler.isObservable('-----#', error: tooMany));
    });
  });
  group('skip', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.skip(2);
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.skip(2);
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.skip(2);
      expect(actual, scheduler.isObservable('-----|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.skip(2);
      expect(actual, scheduler.isObservable('-----#'));
    });
    test('two values and completion', () {
      final input = scheduler.cold('--a---b----|');
      final actual = input.skip(2);
      expect(actual, scheduler.isObservable('-----------|'));
    });
    test('two values and error', () {
      final input = scheduler.cold('--a---b----#');
      final actual = input.skip(2);
      expect(actual, scheduler.isObservable('-----------#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c-d-e-|');
      final actual = input.skip(2);
      expect(actual, scheduler.isObservable('--------c-d-e-|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c-d-e-#');
      final actual = input.skip(2);
      expect(actual, scheduler.isObservable('--------c-d-e-#'));
    });
  });
  group('skipWhile', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.skipWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.skipWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.skipWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('-----|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.skipWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('-----#'));
    });
    test('two values and completion', () {
      final input = scheduler.cold('--a---b----|');
      final actual = input.skipWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('-----------|'));
    });
    test('two values and error', () {
      final input = scheduler.cold('--a---b----#');
      final actual = input.skipWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('-----------#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c-b-a-|');
      final actual = input.skipWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('--------c-b-a-|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c-b-a-#');
      final actual = input.skipWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('--------c-b-a-#'));
    });
    test('predicate throws error', () {
      final input = scheduler.cold<String>('-a-|');
      final actual = input.skipWhile((value) => throw 'Error');
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
      final actual = input.switchAll();
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz-|'));
    });
    test('inner longer', () {
      final input = scheduler.cold('-1---2---3|', values: observables);
      final actual = input.switchAll();
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz|'));
    });
    test('outer error', () {
      final input = scheduler.cold('-3#', values: observables);
      final actual = input.switchAll();
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('inner error', () {
      final input = scheduler.cold('-4--4---4---|', values: observables);
      final actual = input.switchAll();
      expect(actual, scheduler.isObservable<String>('-xyzxyz#'));
    });
    test('overlapping', () {
      final input = scheduler.cold('-3--3-33--|', values: observables);
      final actual = input.switchAll();
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
          input.switchMap((marble) => scheduler.cold<String>(marble));
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz-|'));
    });
    test('inner longer', () {
      final input = scheduler.cold('-1---2---3|', values: marbles);
      final actual =
          input.switchMap((marble) => scheduler.cold<String>(marble));
      expect(actual, scheduler.isObservable<String>('-x---xy--xyz|'));
    });
    test('outer error', () {
      final input = scheduler.cold('-3#', values: marbles);
      final actual =
          input.switchMap((marble) => scheduler.cold<String>(marble));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('inner error', () {
      final input = scheduler.cold('-4--4---4---|', values: marbles);
      final actual =
          input.switchMap((marble) => scheduler.cold<String>(marble));
      expect(actual, scheduler.isObservable<String>('-xyzxyz#'));
    });
    test('project error', () {
      final input = scheduler.cold('-123-|');
      final actual = input.switchMap((observable) => throw 'Error');
      expect(actual, scheduler.isObservable('-#'));
    });
    test('overlapping', () {
      final input = scheduler.cold('-3--3-33--|', values: marbles);
      final actual =
          input.switchMap((marble) => scheduler.cold<String>(marble));
      expect(actual, scheduler.isObservable<String>('-xyzxyxxyz|'));
    });
  });
  group('switchMapTo', () {
    test('outer longer', () {
      final input = scheduler.cold('-a---a---a---|');
      final actual = input.switchMapTo(scheduler.cold<String>('xyz|'));
      expect(actual, scheduler.isObservable<String>('-xyz-xyz-xyz-|'));
    });
    test('inner longer', () {
      final input = scheduler.cold('-a---a---a|');
      final actual = input.switchMapTo(scheduler.cold<String>('xyz|'));
      expect(actual, scheduler.isObservable<String>('-xyz-xyz-xyz|'));
    });
    test('outer error', () {
      final input = scheduler.cold('-a#');
      final actual = input.switchMapTo(scheduler.cold<String>('xyz|'));
      expect(actual, scheduler.isObservable<String>('-x#'));
    });
    test('inner error', () {
      final input = scheduler.cold('-a--a---a---|');
      final actual = input.switchMapTo(scheduler.cold<String>('xyz#'));
      expect(actual, scheduler.isObservable<String>('-xyzxyz#'));
    });
    test('overlapping', () {
      final input = scheduler.cold('-a--a-aa--|');
      final actual = input.switchMapTo(scheduler.cold<String>('xyz|'));
      expect(actual, scheduler.isObservable<String>('-xyzxyxxyz|'));
    });
  });
  group('take', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.take(2);
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.take(2);
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.take(2);
      expect(actual, scheduler.isObservable('--a--|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.take(2);
      expect(actual, scheduler.isObservable('--a--#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c----|');
      final actual = input.take(2);
      expect(actual, scheduler.isObservable('-a--(b|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c----#');
      final actual = input.take(2);
      expect(actual, scheduler.isObservable('-a--(b|)'));
    });
  });
  group('takeLast', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.takeLast(2);
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.takeLast(2);
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.takeLast(2);
      expect(actual, scheduler.isObservable('-----(a|)'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.takeLast(2);
      expect(actual, scheduler.isObservable('-----#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c----|');
      final actual = input.takeLast(2);
      expect(actual, scheduler.isObservable('-------------(bc|)'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c----#');
      final actual = input.takeLast(2);
      expect(actual, scheduler.isObservable('-------------#'));
    });
  });
  group('takeWhile', () {
    test('no value and completion', () {
      final input = scheduler.cold('--|');
      final actual = input.takeWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('--|'));
    });
    test('no value and error', () {
      final input = scheduler.cold('--#');
      final actual = input.takeWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('--#'));
    });
    test('one value and completion', () {
      final input = scheduler.cold('--a--|');
      final actual = input.takeWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('--a--|'));
    });
    test('one value and error', () {
      final input = scheduler.cold('--a--#');
      final actual = input.takeWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('--a--#'));
    });
    test('multiple values completion', () {
      final input = scheduler.cold('-a--b---c----|');
      final actual = input.takeWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('-a--b---|'));
    });
    test('multiple values and error', () {
      final input = scheduler.cold('-a--b---c----#');
      final actual = input.takeWhile((value) => 'ab'.contains(value));
      expect(actual, scheduler.isObservable('-a--b---|'));
    });
    test('predicate throws error', () {
      final input = scheduler.cold<String>('-a-|');
      final actual = input.takeWhile((value) => throw 'Error');
      expect(actual, scheduler.isObservable<String>('-#'));
    });
  });
  group('tap', () {
    test('only completion', () {
      var completed = false;
      final input = scheduler.cold('--|');
      final actual = input.tap(Observer.complete(() => completed = true));
      expect(actual, scheduler.isObservable('--|'));
      expect(completed, isTrue);
    });
    test('only error', () {
      Object erred;
      final input = scheduler.cold('--#');
      final actual =
          input.tap(Observer.error((error, [stack]) => erred = error));
      expect(actual, scheduler.isObservable('--#'));
      expect(erred, 'Error');
    });
    test('mirrors all values', () {
      final values = [];
      final input = scheduler.cold('-a--b---c-|');
      final actual = input.tap(Observer.next(values.add));
      expect(actual, scheduler.isObservable('-a--b---c-|'));
      expect(values, ['a', 'b', 'c']);
    });
    test('values and then error', () {
      final values = [];
      final input = scheduler.cold('-ab--c(de)-#');
      final actual = input.tap(Observer.nextIgnoringErrors(values.add));
      expect(actual, scheduler.isObservable('-ab--c(de)-#'));
      expect(values, ['a', 'b', 'c', 'd', 'e']);
    });
    test('error during next', () {
      final customError = Exception('My Error');
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.tap(Observer.next((value) {
        if (value == 'c') {
          throw customError;
        }
      }));
      expect(actual, scheduler.isObservable('-a-b-#', error: customError));
    });
    test('error during error', () {
      final customError = Exception('My Error');
      final input = scheduler.cold('-a-b-c-#');
      final actual = input.tap(Observer.error((error, [stack]) {
        expect(error, 'Error');
        throw customError;
      }));
      expect(actual, scheduler.isObservable('-a-b-c-#', error: customError));
    });
    test('error during complete', () {
      final customError = Exception('My Error');
      final input = scheduler.cold('-a-b-c-|');
      final actual = input.tap(Observer.complete(() => throw customError));
      expect(actual, scheduler.isObservable('-a-b-c-#', error: customError));
    });
  });
  group('throttle', () {
    test('pass trough values', () {
      final input = scheduler.cold('-a---b---c---|');
      final actual = input.throttleTime(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('-a---b---c---|'));
    });
    test('pass trough values and error', () {
      final input = scheduler.cold('-a---b---c---#');
      final actual = input.throttleTime(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('-a---b---c---#'));
    });
    test('throttling', () {
      final input = scheduler.cold('-ab----|');
      final actual = input.throttleTime(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('-a--b--|'));
    });
    test('throttling custom', () {
      final throttledValues = <String>[];
      final input = scheduler.cold('-ab----|');
      final actual = input.throttle((value) {
        throttledValues.add(value);
        return timer(delay: scheduler.stepDuration * 3);
      });
      expect(actual, scheduler.isObservable('-a--b--|'));
      expect(throttledValues, ['a']);
    });
    test('throttling without leading', () {
      final input = scheduler.cold('-ab----|');
      final actual =
          input.throttleTime(scheduler.stepDuration * 3, leading: false);
      expect(actual, scheduler.isObservable('----b--|'));
    });
    test('throttling without trailing', () {
      final input = scheduler.cold('-ab----|');
      final actual =
          input.throttleTime(scheduler.stepDuration * 3, trailing: false);
      expect(actual, scheduler.isObservable('-a-----|'));
    });
    test('throttling with break inbetween', () {
      final input = scheduler.cold('-ab--------cd--------|');
      final actual = input.throttleTime(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('-a--b------c--d------|'));
    });
    test('complete during throttle', () {
      final input = scheduler.cold('-ab|');
      final actual = input.throttleTime(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('-a-(b|)'));
    });
    test('throwing throttler provider', () {
      final input = scheduler.cold('-a---b---c---|');
      final actual = input.throttle((value) => throw 'Error');
      expect(actual, scheduler.isObservable('-#'));
    });
    test('throwing throttler observable', () {
      final input = scheduler.cold('-a---b---c---|');
      final actual = input.throttle((value) => throwError('Error'));
      expect(actual, scheduler.isObservable('-#'));
    });
  });
  group('timeout', () {
    test('after immediate completion', () {
      final input = scheduler.cold('--|');
      final actual = input.timeout(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('--|'));
    });
    test('after immediate error', () {
      final input = scheduler.cold('--#');
      final actual = input.timeout(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('--#'));
    });
    test('after emission and completion', () {
      final input = scheduler.cold('ab|');
      final actual = input.timeout(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('ab|'));
    });
    test('after emission and error', () {
      final input = scheduler.cold('ab#');
      final actual = input.timeout(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('ab#'));
    });
    test('before immediate completion', () {
      final input = scheduler.cold('----|');
      final actual = input.timeout(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('---#', error: TimeoutError()));
    });
    test('before immediate error', () {
      final input = scheduler.cold('----#');
      final actual = input.timeout(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('---#', error: TimeoutError()));
    });
    test('before emission and completion', () {
      final input = scheduler.cold('abcd|');
      final actual = input.timeout(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('abc#', error: TimeoutError()));
    });
    test('before emission and error', () {
      final input = scheduler.cold('abcd#');
      final actual = input.timeout(scheduler.stepDuration * 3);
      expect(actual, scheduler.isObservable('abc#', error: TimeoutError()));
    });
  });
  group('toList', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.toList();
      expect(actual,
          scheduler.isObservable<List<String>>('--(x|)', values: {'x': []}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.toList();
      expect(actual, scheduler.isObservable<List<String>>('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.toList();
      expect(
          actual,
          scheduler.isObservable('-----(x|)', values: {
            'x': ['a']
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual = input.toList();
      expect(actual, scheduler.isObservable<List<String>>('-----#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.toList();
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': ['a', 'b', 'c']
          }));
    });
    test('multiple values and error', () {
      final input = scheduler.cold<String>('--a--b--c--#');
      final actual = input.toList();
      expect(actual, scheduler.isObservable<List<String>>('-----------#'));
    });
    test('custom constructor', () {
      var creation = 0;
      final input = scheduler.cold<String>('abc|');
      final actual = input.toList(() {
        creation++;
        return <String>[];
      });
      expect(creation, 0);
      expect(
          actual,
          scheduler.isObservable('---(x|)', values: {
            'x': ['a', 'b', 'c']
          }));
      expect(creation, 1);
    });
  });
  group('toMap', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.toMap();
      expect(actual, scheduler.isObservable<Map>('--(x|)', values: {'x': {}}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.toMap();
      expect(actual, scheduler.isObservable<Map>('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.toMap<String, String>();
      expect(
          actual,
          scheduler.isObservable('-----(x|)', values: {
            'x': {'a': 'a'}
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual = input.toMap<String, String>();
      expect(actual, scheduler.isObservable<Map<String, String>>('-----#'));
    });
    test('key selector', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.toMap<String, String>(
          keySelector: (value) => value.toUpperCase());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': {'A': 'a', 'B': 'b', 'C': 'c'}
          }));
    });
    test('value selector', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.toMap<String, String>(
          valueSelector: (value) => value.toUpperCase());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': {'a': 'A', 'b': 'B', 'c': 'C'}
          }));
    });
  });
  group('toListMultimap', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.toListMultimap().map((map) => map.asMap());
      expect(
          actual,
          scheduler.isObservable('--(x|)',
              values: {'x': <dynamic, List<dynamic>>{}}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.toListMultimap();
      expect(actual, scheduler.isObservable<ListMultimap>('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual =
          input.toListMultimap<String, String>().map((map) => map.asMap());
      expect(
          actual,
          scheduler.isObservable('-----(x|)', values: {
            'x': {
              'a': ['a']
            }
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual =
          input.toListMultimap<String, String>().map((map) => map.asMap());
      expect(
          actual, scheduler.isObservable<Map<String, List<String>>>('-----#'));
    });
    test('key selector', () {
      final input = scheduler.cold<String>('--a--a--b--|');
      final actual = input
          .toListMultimap<String, String>(
              keySelector: (value) => value.toUpperCase())
          .map((map) => map.asMap());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': {
              'A': ['a', 'a'],
              'B': ['b']
            }
          }));
    });
    test('value selector', () {
      final input = scheduler.cold<String>('--a--b--b--|');
      final actual = input
          .toListMultimap<String, String>(
              valueSelector: (value) => value.toUpperCase())
          .map((map) => map.asMap());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': {
              'a': ['A'],
              'b': ['B', 'B']
            }
          }));
    });
  });
  group('toSetMultimap', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.toSetMultimap().map((map) => map.asMap());
      expect(
          actual,
          scheduler.isObservable('--(x|)',
              values: {'x': <dynamic, Set<dynamic>>{}}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.toSetMultimap();
      expect(actual, scheduler.isObservable<SetMultimap>('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual =
          input.toSetMultimap<String, String>().map((map) => map.asMap());
      expect(
          actual,
          scheduler.isObservable('-----(x|)', values: {
            'x': {
              'a': {'a'}
            }
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual =
          input.toSetMultimap<String, String>().map((map) => map.asMap());
      expect(
          actual, scheduler.isObservable<Map<String, Set<String>>>('-----#'));
    });
    test('key selector', () {
      final input = scheduler.cold<String>('--a--a--b--|');
      final actual = input
          .toSetMultimap<String, String>(
              keySelector: (value) => value.toUpperCase())
          .map((map) => map.asMap());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': {
              'A': {'a'},
              'B': {'b'}
            }
          }));
    });
    test('value selector', () {
      final input = scheduler.cold<String>('--a--b--b--|');
      final actual = input
          .toSetMultimap<String, String>(
              valueSelector: (value) => value.toUpperCase())
          .map((map) => map.asMap());
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': {
              'a': {'A'},
              'b': {'B'}
            }
          }));
    });
  });
  group('toSet', () {
    test('empty and completion', () {
      final input = scheduler.cold<String>('--|');
      final actual = input.toSet();
      expect(actual,
          scheduler.isObservable<Set<String>>('--(x|)', values: {'x': {}}));
    });
    test('empty and error', () {
      final input = scheduler.cold<String>('--#');
      final actual = input.toSet();
      expect(actual, scheduler.isObservable<Set<String>>('--#'));
    });
    test('single value and completion', () {
      final input = scheduler.cold<String>('--a--|');
      final actual = input.toSet();
      expect(
          actual,
          scheduler.isObservable('-----(x|)', values: {
            'x': {'a'}
          }));
    });
    test('single value and error', () {
      final input = scheduler.cold<String>('--a--#');
      final actual = input.toSet();
      expect(actual, scheduler.isObservable<Set<String>>('-----#'));
    });
    test('multiple values and completion', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.toSet();
      expect(
          actual,
          scheduler.isObservable('-----------(x|)', values: {
            'x': {'a', 'b', 'c'}
          }));
    });
    test('multiple values and error', () {
      final input = scheduler.cold<String>('--a--b--c--#');
      final actual = input.toSet();
      expect(actual, scheduler.isObservable<Set<String>>('-----------#'));
    });
    test('custom constructor', () {
      var creation = 0;
      final input = scheduler.cold<String>('abc|');
      final actual = input.toSet(() {
        creation++;
        return <String>{};
      });
      expect(creation, 0);
      expect(
          actual,
          scheduler.isObservable('---(x|)', values: {
            'x': {'a', 'b', 'c'}
          }));
      expect(creation, 1);
    });
  });
  group('where', () {
    test('first value filterd', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.where((value) => value != 'a');
      expect(actual, scheduler.isObservable('-----b--|'));
    });
    test('second value filtered', () {
      final input = scheduler.cold('--a--b--|');
      final actual = input.where((value) => value != 'b');
      expect(actual, scheduler.isObservable('--a-----|'));
    });
    test('second value filtered and error', () {
      final input = scheduler.cold('--a--b--#');
      final actual = input.where((value) => value != 'b');
      expect(actual, scheduler.isObservable('--a-----#'));
    });
    test('filter throws an error', () {
      final input = scheduler.cold('--a--b--#');
      final actual = input.where((value) => throw 'Error');
      expect(actual, scheduler.isObservable('--#'));
    });
  });
  group('whereType', () {
    const values = {'x': 1};
    test('first value filterd', () {
      final input = scheduler.cold<Object>('--x--a--|', values: values);
      final actual = input.whereType<String>();
      expect(actual, scheduler.isObservable<String>('-----a--|'));
    });
    test('second value filtered', () {
      final input = scheduler.cold<Object>('--a--x--|', values: values);
      final actual = input.whereType<String>();
      expect(actual, scheduler.isObservable<String>('--a-----|'));
    });
    test('second value filtered and error', () {
      final input = scheduler.cold<Object>('--a--x--#', values: values);
      final actual = input.whereType<String>();
      expect(actual, scheduler.isObservable<String>('--a-----#'));
    });
  });
}
