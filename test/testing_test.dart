library rx.test.testing_test;

import 'package:rx/core.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart';

void main() {
  group('marbles', () {
    test('series of values', () {
      final result = TestScheduler.parseEvents<String>('-------a---b');
      expect(result, <TestEvent<String>>[
        TestEvent(7, NextEvent('a')),
        TestEvent(11, NextEvent('b')),
      ]);
    });
    test('series of values with custom mapping', () {
      final result = TestScheduler.parseEvents<int>('-------a---b',
          values: {'a': 1, 'b': 2});
      expect(result, <TestEvent<int>>[
        TestEvent(7, NextEvent(1)),
        TestEvent(11, NextEvent(2)),
      ]);
    });
    test('series of values with completion', () {
      final result = TestScheduler.parseEvents<String>('-------a---b---|');
      expect(result, <TestEvent<String>>[
        TestEvent(7, NextEvent('a')),
        TestEvent(11, NextEvent('b')),
        TestEvent(15, CompleteEvent()),
      ]);
    });
    test('series of values with error', () {
      final result = TestScheduler.parseEvents<String>('-------a---b---#');
      expect(result, <TestEvent<String>>[
        TestEvent(7, NextEvent('a')),
        TestEvent(11, NextEvent('b')),
        TestEvent(15, ErrorEvent('Error')),
      ]);
    });
    test('series of values with custom error', () {
      final error = ArgumentError('Custom error');
      final result =
          TestScheduler.parseEvents<String>('-------a---b---#', error: error);
      expect(result, <TestEvent<String>>[
        TestEvent(7, NextEvent('a')),
        TestEvent(11, NextEvent('b')),
        TestEvent(15, ErrorEvent(error)),
      ]);
    });
    test('subscription and unsubscription', () {
      final result = TestScheduler.parseEvents<String>('---^---!---');
      expect(result, <TestEvent<String>>[
        TestEvent(3, SubscribeEvent()),
        TestEvent(7, UnsubscribeEvent()),
      ]);
    });
    test('invalid subscription and unsubscription', () {
      expect(() => TestScheduler.parseEvents('^^'), throwsArgumentError);
      expect(() => TestScheduler.parseEvents('!!'), throwsArgumentError);
    });
    test('grouped values', () {
      final result = TestScheduler.parseEvents<String>('---(abc)---');
      expect(result, <TestEvent<String>>[
        TestEvent(3, NextEvent('a')),
        TestEvent(3, NextEvent('b')),
        TestEvent(3, NextEvent('c')),
      ]);
    });
    test('invalid grouping', () {
      expect(() => TestScheduler.parseEvents('(('), throwsArgumentError);
      expect(() => TestScheduler.parseEvents('(a'), throwsArgumentError);
      expect(() => TestScheduler.parseEvents(')a'), throwsArgumentError);
    });
    test('ignores whitespaces when parsing', () {
      final result = TestScheduler.parseEvents<String>('--- a\t---b---\n|');
      expect(result, <TestEvent<String>>[
        TestEvent(3, NextEvent('a')),
        TestEvent(7, NextEvent('b')),
        TestEvent(11, CompleteEvent()),
      ]);
    });
  });
}
