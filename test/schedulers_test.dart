library rx.test.schedulers_test;

import 'dart:async';

import 'package:more/iterable.dart';
import 'package:rx/core.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/src/schedulers/settings.dart';
import 'package:test/test.dart';

final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);

Predicate1<DateTime> closeToDateTime(DateTime expected, Duration duration) =>
    (actual) =>
        actual is DateTime &&
        expected.millisecondsSinceEpoch - duration.inMilliseconds <=
            actual.millisecondsSinceEpoch &&
        actual.millisecondsSinceEpoch <=
            expected.millisecondsSinceEpoch + duration.inMilliseconds;

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
    const accuracy = Duration(milliseconds: 2);
    const offset = Duration(milliseconds: 10);
    test('now', () {
      final actual = scheduler.now;
      final expected = DateTime.now();
      expect(actual, closeToDateTime(expected, accuracy));
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
      expect(actual, closeToDateTime(expected, accuracy));
      expect(subscription.isClosed, isTrue);
    });
    test('scheduleRelative', () {
      var actual = epoch;
      final expected = scheduler.now.add(offset);
      final subscription = scheduler.scheduleRelative(offset, () {
        expect(actual, epoch);
        actual = scheduler.now;
      });
      expect(actual, closeToDateTime(expected, accuracy));
      expect(subscription.isClosed, isTrue);
    });
    test('schedulePeriodic', () {
      final actual = <DateTime>[];
      final expected =
          iterate<DateTime>(scheduler.now, (prev) => prev.add(offset))
              .skip(1)
              .take(5);
      final subscription = scheduler.schedulePeriodic(offset, (subscription) {
        actual.add(scheduler.now);
        if (actual.length == 5) {
          subscription.unsubscribe();
        }
      });
      expect(
          actual,
          pairwiseCompare(
              expected,
              (actual, expected) => closeToDateTime(expected, accuracy)(actual),
              'periodic timestamps'));
      expect(subscription.isClosed, isTrue);
    });
  });
  group('root zone', () => testZone(RootZoneScheduler()));
  group('current zone', () => testZone(CurrentZoneScheduler()));
}

void testZone(ZoneScheduler scheduler) {
  const offset = Duration(milliseconds: 25);
  const accuracy = Duration(milliseconds: 10);
  test('now', () {
    final actual = scheduler.now;
    final expected = DateTime.now();
    expect(actual, closeToDateTime(expected, accuracy));
  });
  test('schedule', () async {
    final expected = DateTime.now();
    final completer = Completer<DateTime>();
    final subscription = scheduler.schedule(() {
      completer.complete(scheduler.now);
    });
    expect(await completer.future, closeToDateTime(expected, accuracy));
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
    expect(await completer.future, closeToDateTime(expected, accuracy));
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
    expect(actual, closeToDateTime(expected, accuracy));
  });
  test('scheduleRelative', () async {
    final completer = Completer<DateTime>();
    final expected = scheduler.now.add(offset);
    final subscription = scheduler.scheduleRelative(
        offset, () => completer.complete(scheduler.now));
    expect(subscription.isClosed, isFalse);
    final actual = await completer.future;
    expect(actual, closeToDateTime(expected, accuracy));
  });
  test('schedulePeriodic', () async {
    final completer = Completer<List<DateTime>>();
    final collector = <DateTime>[];
    final expected =
        iterate<DateTime>(scheduler.now, (prev) => prev.add(offset))
            .skip(1)
            .take(5);
    final subscription = scheduler.schedulePeriodic(offset, (subscription) {
      collector.add(scheduler.now);
      if (collector.length == 5) {
        completer.complete(collector);
        subscription.unsubscribe();
      }
    });
    expect(subscription.isClosed, isFalse);
    final actual = await completer.future;
    expect(
        actual,
        pairwiseCompare(
            expected,
            (actual, expected) => closeToDateTime(expected, accuracy)(actual),
            'periodic timestamps'));
    expect(subscription.isClosed, isTrue);
  });
}
