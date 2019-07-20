library rx.test.pipe_test;

import 'package:rx/operators.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart' hide isEmpty;

const Map<String, bool> boolMap = {'t': true, 'f': false};

void main() {
  final scheduler = TestScheduler();
  setUp(scheduler.setUp);
  tearDown(scheduler.tearDown);

  group('pipe', () {
    test('pipe multiple types', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe3<double, int, String>(
        map((v) => 3.9),
        map((v) => v.floor()),
        map((v) => '$v'),
      );
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': '3', 'b': '3', 'c': '3'}));
    });
    test('pipe 2', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe2<String, String>(
        map<String, String>((v) => '1'),
        map<String, String>((v) => '2'),
      );
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': '2', 'b': '2', 'c': '2'}));
    });
    test('pipe 3', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe3<String, String, String>(
        map<String, String>((v) => '1'),
        map<String, String>((v) => '2'),
        map<String, String>((v) => '3'),
      );
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': '3', 'b': '3', 'c': '3'}));
    });
    test('pipe 4', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe4<String, String, String, String>(
        map<String, String>((v) => '1'),
        map<String, String>((v) => '2'),
        map<String, String>((v) => '3'),
        map<String, String>((v) => '4'),
      );
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': '4', 'b': '4', 'c': '4'}));
    });
    test('pipe 5', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe5<String, String, String, String, String>(
        map<String, String>((v) => '1'),
        map<String, String>((v) => '2'),
        map<String, String>((v) => '3'),
        map<String, String>((v) => '4'),
        map<String, String>((v) => '5'),
      );
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': '5', 'b': '5', 'c': '5'}));
    });
    test('pipe 6', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual =
          input.pipe6<String, String, String, String, String, String>(
        map<String, String>((v) => '1'),
        map<String, String>((v) => '2'),
        map<String, String>((v) => '3'),
        map<String, String>((v) => '4'),
        map<String, String>((v) => '5'),
        map<String, String>((v) => '6'),
      );
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': '6', 'b': '6', 'c': '6'}));
    });
    test('pipe 7', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual =
          input.pipe7<String, String, String, String, String, String, String>(
        map<String, String>((v) => '1'),
        map<String, String>((v) => '2'),
        map<String, String>((v) => '3'),
        map<String, String>((v) => '4'),
        map<String, String>((v) => '5'),
        map<String, String>((v) => '6'),
        map<String, String>((v) => '7'),
      );
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': '7', 'b': '7', 'c': '7'}));
    });
    test('pipe 8', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe8<String, String, String, String, String, String,
          String, String>(
        map<String, String>((v) => '1'),
        map<String, String>((v) => '2'),
        map<String, String>((v) => '3'),
        map<String, String>((v) => '4'),
        map<String, String>((v) => '5'),
        map<String, String>((v) => '6'),
        map<String, String>((v) => '7'),
        map<String, String>((v) => '8'),
      );
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': '8', 'b': '8', 'c': '8'}));
    });

    test('pipe 9', () {
      final input = scheduler.cold<String>('--a--b--c--|');
      final actual = input.pipe9<String, String, String, String, String, String,
          String, String, String>(
        map<String, String>((v) => '1'),
        map<String, String>((v) => '2'),
        map<String, String>((v) => '3'),
        map<String, String>((v) => '4'),
        map<String, String>((v) => '5'),
        map<String, String>((v) => '6'),
        map<String, String>((v) => '7'),
        map<String, String>((v) => '8'),
        map<String, String>((v) => '9'),
      );
      expect(
          actual,
          scheduler.isObservable('--a--b--c--|',
              values: {'a': '9', 'b': '9', 'c': '9'}));
    });
  });
}
