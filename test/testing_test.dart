library rx.test.testing_test;

import 'package:rx/testing.dart';
import 'package:test/test.dart';

void main() {
  group('marbles', () {
    test('series of values', () {
      final result = TestScheduler.parseEvents('-------a---b');
      expect(result, [
        ValueEvent(7, 'a'),
        ValueEvent(11, 'b'),
      ]);
    });
    test('series of values with custom mapping', () {
      final result =
          TestScheduler.parseEvents('-------a---b', values: {'a': 1, 'b': 2});
      expect(result, [
        ValueEvent(7, 1),
        ValueEvent(11, 2),
      ]);
    });
    test('series of values with completion', () {
      final result = TestScheduler.parseEvents('-------a---b---|');
      expect(result, [
        ValueEvent(7, 'a'),
        ValueEvent(11, 'b'),
        CompleteEvent(15),
      ]);
    });
    test('series of values with error', () {
      final result = TestScheduler.parseEvents('-------a---b---#');
      expect(result, [
        ValueEvent(7, 'a'),
        ValueEvent(11, 'b'),
        ErrorEvent(15, 'Error'),
      ]);
    });
    test('series of values with custom error', () {
      final error = ArgumentError('Custom error');
      final result =
          TestScheduler.parseEvents('-------a---b---#', error: error);
      expect(result, [
        ValueEvent(7, 'a'),
        ValueEvent(11, 'b'),
        ErrorEvent(15, error),
      ]);
    });
    test('subscription and unsubscription', () {
      final result = TestScheduler.parseEvents('---^---!---');
      expect(result, [
        SubscribeEvent(3),
        UnsubscribeEvent(7),
      ]);
    });
    test('invalid subscription and unsubscription', () {
      expect(() => TestScheduler.parseEvents('^^'), throwsArgumentError);
      expect(() => TestScheduler.parseEvents('!!'), throwsArgumentError);
    });
    test('grouped values', () {
      final result = TestScheduler.parseEvents('---(abc)---');
      expect(result, [
        ValueEvent(3, 'a'),
        ValueEvent(3, 'b'),
        ValueEvent(3, 'c'),
      ]);
    });
    test('invalid grouping', () {
      expect(() => TestScheduler.parseEvents('(('), throwsArgumentError);
      expect(() => TestScheduler.parseEvents('(a'), throwsArgumentError);
      expect(() => TestScheduler.parseEvents(')a'), throwsArgumentError);
    });
    test('ignores whitespaces when parsing', () {
      final result = TestScheduler.parseEvents('--- a\t---b---\n|');
      expect(result, [
        ValueEvent(3, 'a'),
        ValueEvent(7, 'b'),
        CompleteEvent(11),
      ]);
    });
  });
}
