import 'dart:async';

import 'package:checks/checks.dart';
import 'package:more/collection.dart';
import 'package:more/feature.dart';
import 'package:rx/disposables.dart';
import 'package:rx/schedulers.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
const Duration offset = Duration(
  milliseconds: isJavaScript || isWasm ? 200 : 100,
);
const Duration accuracy = Duration(
  milliseconds: isJavaScript || isWasm ? 100 : 25,
);
const int retry = isJavaScript || isWasm ? 10 : 3;

void checkDateTime(
  DateTime actual,
  DateTime expected,
  Duration accuracy, {
  String prefix = '',
}) {
  final duration = actual.difference(expected).abs();
  final reason =
      '$prefix\n'
      'Expected: $expected\n'
      '  Actual: $actual\n'
      'Expected: $accuracy\n'
      '   Delta: $duration';
  check(because: reason, duration.compareTo(accuracy) <= 0).isTrue();
}

void checkDateTimeList(
  List<DateTime> actual,
  List<DateTime> expected,
  Duration accuracy,
) {
  check(actual.length).equals(expected.length);
  for (var i = 0; i < actual.length; i++) {
    checkDateTime(
      actual[i],
      expected[i],
      accuracy * (i + 1),
      prefix: 'Index $i\n',
    );
  }
}

void main() {
  group('settings', () {
    tearDown(() => defaultScheduler = null);
    test('default', () {
      const scheduler = ImmediateScheduler();
      check(defaultScheduler != scheduler).isTrue();
      defaultScheduler = scheduler;
      check(defaultScheduler).equals(scheduler);
    });
    test('replace', () {
      const scheduler = ImmediateScheduler();
      check(defaultScheduler != scheduler).isTrue();
      final subscription = replaceDefaultScheduler(scheduler);
      check(defaultScheduler).equals(scheduler);
      subscription.dispose();
      check(defaultScheduler != scheduler).isTrue();
    });
  });

  group('immediate', () {
    const scheduler = ImmediateScheduler();
    test('now', () {
      final actual = scheduler.now;
      final expected = DateTime.now();
      checkDateTime(actual, expected, accuracy);
    }, retry: retry);

    test('schedule', () {
      var called = 0;
      final subscription = scheduler.schedule(() => ++called);
      check(called).equals(1);
      check(subscription).isDisposed.isTrue();
    });

    test('scheduleIteration', () {
      var called = 0;
      final subscription = scheduler.scheduleIteration(() => ++called < 10);
      check(called).equals(10);
      check(subscription).isDisposed.isTrue();
    });

    test('scheduleAbsolute', () {
      var actual = epoch;
      final expected = scheduler.now.add(offset);
      final subscription = scheduler.scheduleAbsolute(expected, () {
        check(actual).equals(epoch);
        actual = scheduler.now;
      });
      checkDateTime(actual, expected, accuracy);
      check(subscription).isDisposed.isTrue();
    }, retry: retry);

    test('scheduleRelative', () {
      var actual = epoch;
      final expected = scheduler.now.add(offset);
      final subscription = scheduler.scheduleRelative(offset, () {
        check(actual).equals(epoch);
        actual = scheduler.now;
      });
      checkDateTime(actual, expected, accuracy);
      check(subscription).isDisposed.isTrue();
    }, retry: retry);

    test('schedulePeriodic', () {
      final start = scheduler.now;
      final actual = [start];
      final subscription = scheduler.schedulePeriodic(offset, (subscription) {
        actual.add(scheduler.now);
        if (actual.length == 5) {
          subscription.dispose();
        }
      });
      check(subscription).isDisposed.isTrue();
      final expected = iterate<DateTime>(
        start,
        (prev) => prev.add(offset),
      ).take(5).toList();
      checkDateTimeList(expected, actual, accuracy);
    }, retry: retry);
  });

  group('async', () {
    final scheduler = AsyncScheduler();
    const tickScheduler = CurrentZoneScheduler();
    const tickDuration = Duration(milliseconds: 1);
    late Disposable ticker;
    setUp(
      () => ticker = tickScheduler.schedulePeriodic(
        tickDuration,
        (disposable) => scheduler.flush(),
      ),
    );
    tearDown(() => ticker.dispose());
    testScheduler(scheduler);
  });

  group('root zone', () => testScheduler(const RootZoneScheduler()));
  group('current zone', () => testScheduler(const CurrentZoneScheduler()));
}

void testScheduler(Scheduler scheduler) {
  test('now', () {
    final actual = scheduler.now;
    final expected = DateTime.now();
    checkDateTime(actual, expected, accuracy);
  }, retry: retry);

  test('schedule', () async {
    final expected = DateTime.now();
    final completer = Completer<DateTime>();
    final subscription = scheduler.schedule(() {
      completer.complete(scheduler.now);
    });
    final actual = await completer.future;
    checkDateTime(actual, expected, accuracy);
    check(subscription).isDisposed.isFalse();
  }, retry: retry);

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
    check(subscription).isDisposed.isFalse();
    final actual = await completer.future;
    checkDateTime(actual, expected, accuracy);
    check(subscription).isDisposed.isTrue();
    check(called).equals(10);
  });

  test('scheduleAbsolute', () async {
    final completer = Completer<DateTime>();
    final expected = scheduler.now.add(offset);
    final subscription = scheduler.scheduleAbsolute(
      expected,
      () => completer.complete(scheduler.now),
    );
    check(subscription).isDisposed.isFalse();
    final actual = await completer.future;
    checkDateTime(actual, expected, accuracy);
  }, retry: retry);

  test('scheduleRelative', () async {
    final completer = Completer<DateTime>();
    final expected = scheduler.now.add(offset);
    final subscription = scheduler.scheduleRelative(
      offset,
      () => completer.complete(scheduler.now),
    );
    check(subscription).isDisposed.isFalse();
    final actual = await completer.future;
    checkDateTime(actual, expected, accuracy);
  });

  test('schedulePeriodic', () async {
    final completer = Completer<void>();
    final start = scheduler.now;
    final actual = [start];
    final subscription = scheduler.schedulePeriodic(offset, (subscription) {
      actual.add(scheduler.now);
      if (actual.length == 5) {
        completer.complete();
        subscription.dispose();
      }
    });
    check(subscription).isDisposed.isFalse();
    await completer.future;
    final expected = iterate<DateTime>(
      start,
      (prev) => prev.add(offset),
    ).take(5).toList();
    checkDateTimeList(expected, actual, accuracy);
    check(subscription).isDisposed.isTrue();
  }, retry: retry);
}
