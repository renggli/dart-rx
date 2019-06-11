library rx.test.constructors_test;

import 'package:rx/constructors.dart';
import 'package:rx/core.dart';
import 'package:rx/operators.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart';

void main() {
  final scheduler = TestScheduler();
  scheduler.install();

  group('concat', () {
    test('elements from 3 different sources', () {
      final actual = concat([
        scheduler.cold('-a-b-c-|'),
        scheduler.cold('-0-1-|'),
        scheduler.cold('-w-x-y-z-|'),
      ]);
      expect(actual, scheduler.isObservable('-a-b-c--0-1--w-x-y-z-|'));
    });
    test('elements from 3 same sources', () {
      final source = scheduler.cold('--i-j-|');
      final actual = concat([source, source, source]);
      expect(actual, scheduler.isObservable('--i-j---i-j---i-j-|'));
    });
    test('no elements from empty sources', () {
      final actual = concat([
        scheduler.cold('--|'),
        scheduler.cold('---|'),
        scheduler.cold('-|'),
      ]);
      expect(actual, scheduler.isObservable('------|'));
    });
    test('no elements after error', () {
      final actual = concat([
        scheduler.cold('-a-|'),
        scheduler.cold('-#'),
        scheduler.cold('-b-|'),
      ]);
      expect(actual, scheduler.isObservable('-a--#'));
    });
  });
  group('create', () {});
  group('defer', () {});
  group('empty', () {
    test('immediately completes', () {
      final actual = empty();
      expect(actual, scheduler.isObservable('|'));
    });
    test('synchronous by default', () {
      final actual = empty();
      var seen = false;
      actual.subscribe(Observer.complete(() => seen = true));
      expect(seen, isTrue);
    });
    test('asynchronous with custom scheduler', () {
      final actual = empty(scheduler: scheduler);
      var seen = false;
      actual.subscribe(Observer.complete(() => seen = true));
      expect(seen, isFalse);
      scheduler.flush();
      expect(seen, isTrue);
    });
  });
  group('forkJoin', () {
    test('joins the last values', () {
      final actual = forkJoin<String>([
        scheduler.cold('--a--b--c--d--|'),
        scheduler.cold('(b|)'),
        scheduler.cold('--1--2--3--|'),
      ]);
      expect(
          actual,
          scheduler.isObservable<List<String>>('--------------(x|)', values: {
            'x': ['d', 'b', '3']
          }));
    });
    test('accepts null values', () {
      final actual = forkJoin<String>([
        scheduler.cold('--a--b--c--d--|'),
        scheduler.cold('(b|)', values: {'b': null}),
        scheduler.cold('--1--2--3--|'),
      ]);
      expect(
          actual,
          scheduler.isObservable<List<String>>('--------------(x|)', values: {
            'x': ['d', null, '3']
          }));
    });
    test('accepts a single observable', () {
      final actual = forkJoin<String>([
        scheduler.cold('---a---b---c---d---|'),
      ]);
      expect(
          actual,
          scheduler
              .isObservable<List<String>>('-------------------(x|)', values: {
            'x': ['d']
          }));
    });
    test('completes empty with empty observable', () {
      final actual = forkJoin<String>([
        scheduler.cold('--a--b--c--d--|'),
        scheduler.cold('(b|)'),
        scheduler.cold('------------------|'),
      ]);
      expect(
          actual, scheduler.isObservable<List<String>>('------------------|'));
    });
    test('completes early with empty observable', () {
      final actual = forkJoin<String>([
        scheduler.cold('--a--b--c--d--|'),
        scheduler.cold('(b|)'),
        scheduler.cold('-----|'),
      ]);
      expect(actual, scheduler.isObservable<List<String>>('-----|'));
    });
    test('completes when all sources are empty', () {
      final actual = forkJoin<String>([
        scheduler.cold('---------|'),
        scheduler.cold('---------------|'),
        scheduler.cold('-----|'),
      ]);
      expect(actual, scheduler.isObservable<List<String>>('-----|'));
    });
    test('completes when one never completes, but another is emptuy', () {
      final actual = forkJoin<String>([
        scheduler.cold('--------------'),
        scheduler.cold('--|'),
      ]);
      expect(actual, scheduler.isObservable<List<String>>('--|'));
    });
    test('completes immediately when empty', () {
      final actual = forkJoin<String>([]);
      expect(actual, scheduler.isObservable<List<String>>('|'));
    });
    test('raises error when any of the sources raises error', () {
      final actual = forkJoin<String>([
        scheduler.cold('--a--b--c--d--|'),
        scheduler.cold('(b|)'),
        scheduler.cold('--1--2-#'),
      ]);
      expect(actual, scheduler.isObservable<List<String>>('-------#'));
    });
  });
  group('future', () {});
  group('iff', () {
    test('true branch', () {
      final actual = iff(
        () => true,
        scheduler.cold('-t--|'),
        scheduler.cold('--f-|'),
      );
      expect(actual, scheduler.isObservable('-t--|'));
    });
    test('false branch', () {
      final actual = iff(
        () => false,
        scheduler.cold('-t--|'),
        scheduler.cold('--f-|'),
      );
      expect(actual, scheduler.isObservable('--f-|'));
    });
  });
  group('iterable', () {
    test('completes on empty collection', () {
      final actual = fromIterable(<String>[]);
      expect(actual, scheduler.isObservable<String>('|'));
    });
    test('emits all the values', () {
      final actual = fromIterable(['a', 'b', 'c']);
      expect(actual, scheduler.isObservable<String>('(abc|)'));
    });
  });
  group('just', () {
    test('immediately emits value', () {
      final actual = just('a');
      expect(actual, scheduler.isObservable<String>('(a|)'));
    });
    test('immediately emits null', () {
      final actual = just<String>(null);
      expect(
          actual, scheduler.isObservable<String>('(a|)', values: {'a': null}));
    });
    test('synchronous by default', () {
      final actual = just('a');
      String seenValue;
      actual.subscribe(Observer.next((value) => seenValue = value));
      expect(seenValue, 'a');
    });
    test('asynchronous with custom scheduler', () {
      final actual = just('a', scheduler: scheduler);
      String seenValue;
      actual.subscribe(Observer.next((value) => seenValue = value));
      expect(seenValue, isNull);
      scheduler.flush();
      expect(seenValue, 'a');
    });
  });
  group('merge', () {
    test('merges two interleaving sequences', () {
      final actual = merge([
        scheduler.cold<String>('--a-----b-----c----|'),
        scheduler.cold<String>('-----x-----y-----z---|'),
      ]);
      expect(actual, scheduler.isObservable<String>('--a--x--b--y--c--z---|'));
    });
    test('merges two overlapping sequences', () {
      final actual = merge([
        scheduler.cold<String>('--a--b--c--|'),
        scheduler.cold<String>('--x--y--z--|'),
      ]);
      expect(actual, scheduler.isObservable<String>('--(ax)--(by)--(cz)--|'));
    });
    test('merges throwing sequence', () {
      final actual = merge([
        scheduler.cold<String>('--a--#'),
        scheduler.cold<String>('--x-----y--|'),
      ]);
      expect(actual, scheduler.isObservable<String>('--(ax)--#'));
    });
    test('merges many sequences', () {
      final actual = merge([
        scheduler.cold<String>('a--|'),
        scheduler.cold<String>('-b--|'),
        scheduler.cold<String>('--c--|'),
        scheduler.cold<String>('---d--|'),
        scheduler.cold<String>('----e--|'),
        scheduler.cold<String>('-----f--|'),
      ]);
      expect(actual, scheduler.isObservable<String>('abcdef--|'));
    });
  });
  group('never', () {
    test('immediately closed', () {
      final actual = never();
      final subscription = actual.subscribe(Observer(
        next: (value) => fail('No value expected'),
        error: (error, [stack]) => fail('No error expected'),
        complete: () => fail('No completion expected'),
      ));
      expect(subscription.isClosed, isTrue);
    });
  });
  group('stream', () {});
  group('throwError', () {
    test('immediately throws', () {
      final error = Exception('My Error');
      final actual = throwError(error);
      expect(actual, scheduler.isObservable('#', error: error));
    });
    test('synchronous by default', () {
      final error = Exception('My Error');
      final actual = throwError(error);
      Exception seenError;
      actual.subscribe(Observer.error((error, [stack]) => seenError = error));
      expect(seenError, error);
    });
    test('asynchronous with custom scheduler', () {
      final error = Exception('My Error');
      final actual = throwError(error, scheduler: scheduler);
      Exception seenError;
      actual.subscribe(Observer.error((error, [stack]) => seenError = error));
      expect(seenError, isNull);
      scheduler.flush();
      expect(seenError, error);
    });
  });
  group('timer', () {
    final values = Map.fromIterables(
      List.generate(10, (i) => '$i'),
      List.generate(10, (i) => i),
    );
    test('no delay', () {
      final actual = timer();
      expect(actual, scheduler.isObservable('(0|)', values: values));
    });
    test('delay', () {
      final actual = timer(delay: scheduler.stepDuration * 5);
      expect(actual, scheduler.isObservable('-----(0|)', values: values));
    });
    test('periodic', () {
      final actual = timer(period: scheduler.stepDuration * 2).lift(take(5));
      expect(actual, scheduler.isObservable('0-1-2-3-(4|)', values: values));
    });
    test('delay & periodic', () {
      final actual = timer(
              delay: scheduler.stepDuration * 3,
              period: scheduler.stepDuration * 2)
          .lift(take(5));
      expect(actual, scheduler.isObservable('---0-1-2-3-(4|)', values: values));
    });
  });
}
