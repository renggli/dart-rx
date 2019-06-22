library rx.test.testing_test;

import 'package:rx/core.dart';
import 'package:rx/src/testing/test_event_sequence.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart';

void main() {
  group('marbles', () {
    void expectParse<T>(String marbles, List<TestEvent<T>> events,
        {Map<String, T> values = const {},
        Object error = 'Error',
        bool toMarbles: true}) {
      final result = TestEventSequence<T>.fromString(marbles,
          values: values, error: error);
      expect(result.events, events);
      if (toMarbles) {
        expect(result.toMarbles(), marbles);
      }
    }

    test('series of values', () {
      expectParse<String>('-------a---b', [
        TestEvent(7, NextEvent('a')),
        TestEvent(11, NextEvent('b')),
      ]);
    });
    test('series of values with custom mapping', () {
      expectParse<int>('-------a---b', [
        TestEvent(7, NextEvent(1)),
        TestEvent(11, NextEvent(2)),
      ], values: {
        'a': 1,
        'b': 2
      });
    });
    test('inferred character mapping', () {
      final result = TestEventSequence<int>([
        TestEvent(1, NextEvent(1)),
        TestEvent(3, NextEvent(2)),
        TestEvent(5, NextEvent(1)),
      ]);
      expect(result.toMarbles(), '-a-b-a');
    });
    test('inferred string character mapping', () {
      final result = TestEventSequence<String>([
        TestEvent(1, NextEvent('x')),
        TestEvent(3, NextEvent('yy')),
        TestEvent(5, NextEvent('x')),
      ]);
      expect(result.toMarbles(), '-x-a-x');
    });
    test('series of values with completion', () {
      expectParse<String>('-------a---b---|', [
        TestEvent(7, NextEvent('a')),
        TestEvent(11, NextEvent('b')),
        TestEvent(15, CompleteEvent()),
      ]);
    });
    test('series of values with error', () {
      expectParse<String>('-------a---b---#', [
        TestEvent(7, NextEvent('a')),
        TestEvent(11, NextEvent('b')),
        TestEvent(15, ErrorEvent('Error')),
      ]);
    });
    test('series of values with custom error', () {
      final error = ArgumentError('Custom error');
      expectParse<String>(
          '-------a---b---#',
          [
            TestEvent(7, NextEvent('a')),
            TestEvent(11, NextEvent('b')),
            TestEvent(15, ErrorEvent(error)),
          ],
          error: error);
    });
    test('subscription and unsubscription', () {
      expectParse<String>('---^---!', [
        TestEvent(3, SubscribeEvent()),
        TestEvent(7, UnsubscribeEvent()),
      ]);
    });
    test('invalid subscription and unsubscription', () {
      expect(() => TestEventSequence<String>.fromString('^^'),
          throwsArgumentError);
      expect(() => TestEventSequence<String>.fromString('!!'),
          throwsArgumentError);
    });
    test('grouped values', () {
      expectParse<String>('---(abc)', [
        TestEvent(3, NextEvent('a')),
        TestEvent(3, NextEvent('b')),
        TestEvent(3, NextEvent('c')),
      ]);
    });
    test('invalid grouping', () {
      expect(() => TestEventSequence<String>.fromString('(('),
          throwsArgumentError);
      expect(() => TestEventSequence<String>.fromString('(a'),
          throwsArgumentError);
      expect(() => TestEventSequence<String>.fromString(')a'),
          throwsArgumentError);
    });
    test('ignores whitespaces when parsing', () {
      expectParse<String>(
          '--- a\t---b---\n|',
          [
            TestEvent(3, NextEvent('a')),
            TestEvent(7, NextEvent('b')),
            TestEvent(11, CompleteEvent()),
          ],
          toMarbles: false);
    });
  });
}
