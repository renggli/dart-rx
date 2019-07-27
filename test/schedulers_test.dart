library rx.test.schedulers_test;

import 'dart:async';

import 'package:more/iterable.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/src/schedulers/settings.dart';
import 'package:rx/src/shared/constants.dart';
import 'package:test/test.dart';

final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
final Duration offset = Duration(milliseconds: isJavaScript ? 200 : 100);
final Duration accuracy = Duration(milliseconds: isJavaScript ? 50 : 25);

void expectDateTime(DateTime actual, DateTime expected, Duration accuracy,
    {String prefix = ''}) {
  final duration = actual.difference(expected).abs();
  final reason = '$prefix\n'
      'Expected: $expected\n'
      '  Actual: $actual\n'
      'Expected: $accuracy\n'
      '   Delta: $duration';
  expect(duration.compareTo(accuracy) <= 0, isTrue, reason: reason);
}

void expectDateTimeList(
    List<DateTime> actual, List<DateTime> expected, Duration accuracy) {
  expect(actual.length, expected.length);
  for (var i = 0; i < actual.length; i++) {
    expectDateTime(actual[i], expected[i], accuracy * (i + 1),
        prefix: 'Index $i\n');
  }
}

void main() {
  group('settings', () {
    tearDown(() => defaultScheduler = null);
    test('default', () {
      const scheduler = ImmediateScheduler();
      expect(defaultScheduler, isNot(scheduler));
      defaultScheduler = scheduler;
      expect(defaultScheduler, scheduler);
    });
    test('replace', () {
      const scheduler = ImmediateScheduler();
      expect(defaultScheduler, isNot(scheduler));
      final subscription = replaceDefaultScheduler(scheduler);
      expect(defaultScheduler, scheduler);
      subscription.unsubscribe();
      expect(defaultScheduler, isNot(scheduler));
    });
  });
  group('immediate', () {
    const scheduler = ImmediateScheduler();
    test('now', () {
      final actual = scheduler.now;
      final expected = DateTime.now();
      expectDateTime(actual, expected, accuracy);
    });
    test('schedule', () {
      var called = 0;
      final subscription = scheduler.schedule(() => ++called);
      expect(called, 1);
      expect(subscription.isClosed, isTrue);
    });
    test('scheduleIteration', () {
      var called = 0;
      final subscription = scheduler.scheduleIteration(() => ++called < 10);
      expect(called, 10);
      expect(subscription.isClosed, isTrue);
    });
    test('scheduleAbsolute', () {
      var actual = epoch;
      final expected = scheduler.now.add(offset);
      final subscription = scheduler.scheduleAbsolute(expected, () {
        expect(actual, epoch);
        actual = scheduler.now;
      });
      expectDateTime(actual, expected, accuracy);
      expect(subscription.isClosed, isTrue);
    });
    test('scheduleRelative', () {
      var actual = epoch;
      final expected = scheduler.now.add(offset);
      final subscription = scheduler.scheduleRelative(offset, () {
        expect(actual, epoch);
        actual = scheduler.now;
      });
      expectDateTime(actual, expected, accuracy);
      expect(subscription.isClosed, isTrue);
    });
    test('schedulePeriodic', () {
      final start = scheduler.now;
      final actual = [start];
      final subscription = scheduler.schedulePeriodic(offset, (subscription) {
        actual.add(scheduler.now);
        if (actual.length == 5) {
          subscription.unsubscribe();
        }
      });
      expect(subscription.isClosed, isTrue);
      final expected =
          iterate<DateTime>(start, (prev) => prev.add(offset)).take(5).toList();
      expectDateTimeList(expected, actual, accuracy);
    });
  });
  group('root zone', () => testZone(RootZoneScheduler()));
  group('current zone', () => testZone(CurrentZoneScheduler()));
}

void testZone(ZoneScheduler scheduler) {
  test('now', () {
    final actual = scheduler.now;
    final expected = DateTime.now();
    expectDateTime(actual, expected, accuracy);
  });
  test('schedule', () async {
    final expected = DateTime.now();
    final completer = Completer<DateTime>();
    final subscription = scheduler.schedule(() {
      completer.complete(scheduler.now);
    });
    final actual = await completer.future;
    expectDateTime(actual, expected, accuracy);
    expect(subscription.isClosed, isFalse);
  });
  test('scheduleIteration', () async {
    var called = 0;
    final expected = DateTime.now();
    final completer = Completer<DateTime>();
    final subscription = scheduler.scheduleIteration(() {
      called++;
      if (called < 10) {
        return true;
      } else {
        completer.complete(scheduler.now);
        return false;
      }
    });
    expect(subscription.isClosed, isFalse);
    final actual = await completer.future;
    expectDateTime(actual, expected, accuracy);
    expect(subscription.isClosed, isTrue);
    expect(called, 10);
  });
  test('scheduleAbsolute', () async {
    final completer = Completer<DateTime>();
    final expected = scheduler.now.add(offset);
    final subscription = scheduler.scheduleAbsolute(
        expected, () => completer.complete(scheduler.now));
    expect(subscription.isClosed, isFalse);
    final actual = await completer.future;
    expectDateTime(actual, expected, accuracy);
  });
  test('scheduleRelative', () async {
    final completer = Completer<DateTime>();
    final expected = scheduler.now.add(offset);
    final subscription = scheduler.scheduleRelative(
        offset, () => completer.complete(scheduler.now));
    expect(subscription.isClosed, isFalse);
    final actual = await completer.future;
    expectDateTime(actual, expected, accuracy);
  });
  test('schedulePeriodic', () async {
    final completer = Completer();
    final start = scheduler.now;
    final actual = [start];
    final subscription = scheduler.schedulePeriodic(offset, (subscription) {
      actual.add(scheduler.now);
      if (actual.length == 5) {
        completer.complete();
        subscription.unsubscribe();
      }
    });
    expect(subscription.isClosed, isFalse);
    await completer.future;
    final expected =
        iterate<DateTime>(start, (prev) => prev.add(offset)).take(5).toList();
    expectDateTimeList(expected, actual, accuracy);
    expect(subscription.isClosed, isTrue);
  });
}
