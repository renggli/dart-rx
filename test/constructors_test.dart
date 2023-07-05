import 'package:rx/constructors.dart';
import 'package:rx/core.dart';
import 'package:rx/disposables.dart';
import 'package:rx/operators.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart';

void main() {
  final scheduler = TestScheduler();
  setUp(scheduler.setUp);
  tearDown(scheduler.tearDown);

  group('combine latest', () {
    test('empty sequence', () {
      final actual = combineLatest<String>([]);
      expect(actual, scheduler.isObservable<List<String>>('|'));
    });
    test('basic sequence', () {
      final actual = combineLatest<String>([
        scheduler.cold('-a---e|'),
        scheduler.cold('--b-d-|'),
        scheduler.cold('---c--|'),
      ]);
      expect(
          actual,
          scheduler.isObservable('---xyz|', values: {
            'x': ['a', 'b', 'c'],
            'y': ['a', 'd', 'c'],
            'z': ['e', 'd', 'c'],
          }));
    });
    test('different length', () {
      final actual = combineLatest<String>([
        scheduler.cold('-a---e|'),
        scheduler.cold('--b-d|'),
        scheduler.cold('---c|'),
      ]);
      expect(
          actual,
          scheduler.isObservable('---xyz|', values: {
            'x': ['a', 'b', 'c'],
            'y': ['a', 'd', 'c'],
            'z': ['e', 'd', 'c'],
          }));
    });
    test('repeated values', () {
      final actual = combineLatest<String>([
        scheduler.cold('-ab-----|'),
        scheduler.cold('---cd---|'),
        scheduler.cold('-----ef-|'),
      ]);
      expect(
          actual,
          scheduler.isObservable('-----xy-|', values: {
            'x': ['b', 'd', 'e'],
            'y': ['b', 'd', 'f'],
          }));
    });
    test('early error', () {
      final actual = combineLatest<String>([
        scheduler.cold('-a---e|'),
        scheduler.cold('--#'),
        scheduler.cold('---c--|'),
      ]);
      expect(actual, scheduler.isObservable<List<String>>('--#'));
    });
    test('late error', () {
      final actual = combineLatest<String>([
        scheduler.cold('-a---#'),
        scheduler.cold('--b-d-|'),
        scheduler.cold('---c--|'),
      ]);
      expect(
          actual,
          scheduler.isObservable('---xy#', values: {
            'x': ['a', 'b', 'c'],
            'y': ['a', 'd', 'c'],
          }));
    });
  });
  group('concat', () {
    test('elements from 3 different sources', () {
      final actual = concat<String>([
        scheduler.cold<String>('-a-b-c-|'),
        scheduler.cold<String>('-0-1-|'),
        scheduler.cold<String>('-w-x-y-z-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-a-b-c--0-1--w-x-y-z-|'));
    });
    test('elements from 3 same sources', () {
      final source = scheduler.cold<String>('--i-j-|');
      final actual = concat<String>([source, source, source]);
      expect(actual, scheduler.isObservable<String>('--i-j---i-j---i-j-|'));
    });
    test('no elements from empty sources', () {
      final actual = concat<String>([
        scheduler.cold<String>('--|'),
        scheduler.cold<String>('---|'),
        scheduler.cold<String>('-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('------|'));
    });
    test('no elements after error', () {
      final actual = concat<String>([
        scheduler.cold<String>('-a-|'),
        scheduler.cold<String>('-#'),
        scheduler.cold<String>('-b-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-a--#'));
    });
  });
  group('create', () {
    test('complete sequence of values', () {
      final actual = create<String>((subscriber) {
        subscriber.next('a');
        subscriber.next('b');
        subscriber.complete();
      });
      expect(actual, scheduler.isObservable<String>('(ab|)'));
    });
    test('error sequence of values', () {
      final actual = create<String>((subscriber) {
        subscriber.next('a');
        subscriber.next('b');
        subscriber.error('Error', StackTrace.current);
      });
      expect(actual, scheduler.isObservable<String>('(ab#)'));
    });
    test('throws an error while creating values', () {
      final actual = create<String>((subscriber) {
        subscriber.next('a');
        subscriber.next('b');
        throw 'Error';
      });
      expect(actual, scheduler.isObservable<String>('(ab#)'));
    });
    test('calls disposable when unsubscribed', () {
      var disposed = false;
      final actual = create<String>((subscriber) {
        subscriber.next('a');
        subscriber.add(ActionDisposable(() => disposed = true));
      });
      expect(actual, scheduler.isObservable<String>('a'));
      expect(disposed, isFalse);
      actual.subscribe(Observer()).dispose();
      expect(disposed, isTrue);
    });
  });
  group('defer', () {
    test('complete value', () {
      var seen = false;
      final actual = defer(() {
        seen = true;
        return just('a');
      });
      expect(seen, isFalse);
      expect(actual, scheduler.isObservable<String>('(a|)'));
      expect(seen, isTrue);
    });
    test('throws error', () {
      var seen = false;
      final actual = defer<String>(() {
        seen = true;
        throw 'Error';
      });
      expect(seen, isFalse);
      expect(actual, scheduler.isObservable<String>('#'));
      expect(seen, isTrue);
    });
    test('does not return', () {
      var seen = false;
      final actual = defer<String>(() {
        seen = true;
        return empty();
      });
      expect(seen, isFalse);
      expect(actual, scheduler.isObservable<String>('|'));
      expect(seen, isTrue);
    });
  });
  group('empty', () {
    test('immediately completes', () {
      final actual = empty();
      expect(actual, scheduler.isObservable<Never>('|'));
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
          scheduler.isObservable('--------------(x|)', values: {
            'x': ['d', 'b', '3']
          }));
    });
    test('accepts a single observable', () {
      final actual = forkJoin<String>([
        scheduler.cold('---a---b---c---d---|'),
      ]);
      expect(
          actual,
          scheduler.isObservable('-------------------(x|)', values: {
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
    test('completes when one never completes, but another is empty', () {
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
  group('iff', () {
    test('true branch', () {
      final actual = iff(
        () => true,
        scheduler.cold<String>('-t--|'),
        scheduler.cold<String>('--f-|'),
      );
      expect(actual, scheduler.isObservable<String>('-t--|'));
    });
    test('false branch', () {
      final actual = iff<String>(
        () => false,
        scheduler.cold('-t--|'),
        scheduler.cold('--f-|'),
      );
      expect(actual, scheduler.isObservable<String>('--f-|'));
    });
  });
  group('just', () {
    test('immediately emits value', () {
      final actual = just('a');
      expect(actual, scheduler.isObservable<String>('(a|)'));
    });
    test('synchronous by default', () {
      final actual = just('a');
      late String seen;
      actual.subscribe(Observer.next((value) => seen = value));
      expect(seen, 'a');
    });
    test('asynchronous with custom scheduler', () {
      final actual = just('a', scheduler: scheduler);
      String? seen;
      actual.subscribe(Observer.next((value) => seen = value));
      expect(seen, isNull);
      scheduler.flush();
      expect(seen, 'a');
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
        error: (error, stackTrace) => fail('No error expected'),
        complete: () => fail('No completion expected'),
      ));
      expect(subscription.isDisposed, isTrue);
    });
  });
  group('race', () {
    test('no observables', () {
      final actual = race<String>([]);
      expect(actual, scheduler.isObservable<String>('|'));
    });
    test('single observable', () {
      final actual = race<String>([
        scheduler.cold<String>('-a-b-c-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-a-b-c-|'));
    });
    test('two observables and early completion', () {
      final actual = race<String>([
        scheduler.cold<String>('-|'),
        scheduler.cold<String>('--x-y-z-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-|'));
    });
    test('two observables and completion', () {
      final actual = race<String>([
        scheduler.cold<String>('-a-|'),
        scheduler.cold<String>('--x-y-z-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-a-|'));
    });
    test('two observables and late completion', () {
      final actual = race<String>([
        scheduler.cold<String>('-a-b-|'),
        scheduler.cold<String>('--x-y-z-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-a-b-|'));
    });
    test('two observables and early error', () {
      final actual = race<String>([
        scheduler.cold<String>('-#'),
        scheduler.cold<String>('--x-y-z-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-#'));
    });
    test('two observables and error', () {
      final actual = race<String>([
        scheduler.cold<String>('-a-#'),
        scheduler.cold<String>('--x-y-z-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-a-#'));
    });
    test('two observables and late error', () {
      final actual = race<String>([
        scheduler.cold<String>('-a-b-#'),
        scheduler.cold<String>('--x-y-z-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-a-b-#'));
    });
    test('two observables and early completion', () {
      final actual = race<String>([
        scheduler.cold<String>('-|'),
        scheduler.cold<String>('--x-y-z-|'),
      ]);
      expect(actual, scheduler.isObservable<String>('-|'));
    });
    test('multiple observables and losers throw', () {
      final actual = race<String>([
        scheduler.cold<String>('---a-#'),
        scheduler.cold<String>('-1-2-3-4-|'),
        scheduler.cold<String>('--x-y-#'),
      ]);
      expect(actual, scheduler.isObservable<String>('-1-2-3-4-|'));
    });
  });
  group('throwError', () {
    test('immediately throws', () {
      final error = Exception('My Error');
      final actual = throwError(error);
      expect(actual, scheduler.isObservable<String>('#', error: error));
    });
    test('synchronous by default', () {
      final error = Exception('My Error');
      final actual = throwError(error);
      late Object seen;
      actual.subscribe(Observer.error((error, stackTrace) => seen = error));
      expect(seen, error);
    });
    test('asynchronous with custom scheduler', () {
      final error = Exception('My Error');
      final actual = throwError(error, scheduler: scheduler);
      Object? seen;
      actual.subscribe(Observer.error((error, stackTrace) => seen = error));
      expect(seen, isNull);
      scheduler.flush();
      expect(seen, error);
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
      final actual = timer(period: scheduler.stepDuration * 2).take(5);
      expect(actual, scheduler.isObservable('0-1-2-3-(4|)', values: values));
    });
    test('delay & periodic', () {
      final actual = timer(
              delay: scheduler.stepDuration * 3,
              period: scheduler.stepDuration * 2)
          .take(5);
      expect(actual, scheduler.isObservable('---0-1-2-3-(4|)', values: values));
    });
  });
  group('zip', () {
    test('empty sequence', () {
      final actual = zip<String>([]);
      expect(actual, scheduler.isObservable<List<String>>('|'));
    });
    test('basic sequence', () {
      final actual = zip<String>([
        scheduler.cold('-a---e|'),
        scheduler.cold('--b-d-|'),
        scheduler.cold('---c--|'),
      ]);
      expect(
          actual,
          scheduler.isObservable('---x--|', values: {
            'x': ['a', 'b', 'c'],
          }));
    });
    test('different length', () {
      final actual = zip<String>([
        scheduler.cold('-a---e-|'),
        scheduler.cold('--b-d-|'),
        scheduler.cold('---c-|'),
      ]);
      expect(
          actual,
          scheduler.isObservable('---x-|', values: {
            'x': ['a', 'b', 'c'],
          }));
    });
    test('repeated values', () {
      final actual = zip<String>([
        scheduler.cold('-ab-----|'),
        scheduler.cold('---cd---|'),
        scheduler.cold('-----ef-|'),
      ]);
      expect(
          actual,
          scheduler.isObservable('-----xy-|', values: {
            'x': ['a', 'c', 'e'],
            'y': ['b', 'd', 'f'],
          }));
    });
    test('early error', () {
      final actual = zip<String>([
        scheduler.cold('-a---e|'),
        scheduler.cold('--#'),
        scheduler.cold('---c--|'),
      ]);
      expect(actual, scheduler.isObservable<List<String>>('--#'));
    });
    test('late error', () {
      final actual = zip<String>([
        scheduler.cold('-a---#'),
        scheduler.cold('--b-d-|'),
        scheduler.cold('---c--|'),
      ]);
      expect(
          actual,
          scheduler.isObservable('---x-#', values: {
            'x': ['a', 'b', 'c'],
            'y': ['a', 'd', 'c'],
          }));
    });
  });
}
