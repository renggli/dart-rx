library rx.test.constructors_test;

import 'package:rx/constructors.dart';
import 'package:rx/core.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart';

void main() {
  final scheduler = TestScheduler();
  scheduler.install();

  group('concat', () {});
  group('create', () {});
  group('defer', () {});
  group('empty', () {
    test('completes immediately', () {
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
    test('does not complete when one of the sources never completes', () {
      final actual = forkJoin<String>([
        scheduler.cold('--------------'),
        scheduler.cold('-a---b--c--|'),
      ]);
      expect(actual, scheduler.isObservable<List<String>>('-'));
    }, skip: 'infrastructure is broken');
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
  group('iterable', () {});
  group('just', () {});
  group('never', () {});
  group('stream', () {});
  group('throwError', () {});
  group('timer', () {});
}
