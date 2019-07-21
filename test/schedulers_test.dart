library rx.test.schedulers_test;

import 'package:rx/core.dart';
import 'package:rx/schedulers.dart';
import 'package:test/test.dart';

void main() {
  group('immediate', () {
    const scheduler = ImmediateScheduler();
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    test('now', () {
      final actual = scheduler.now.millisecondsSinceEpoch;
      final expected = DateTime.now().millisecondsSinceEpoch;
      expect(actual, closeTo(expected, 2));
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
      final expected = scheduler.now.add(Duration(milliseconds: 10));
      final subscription = scheduler.scheduleAbsolute(expected, () {
        expect(actual, epoch);
        actual = scheduler.now;
      });
      expect(actual.millisecondsSinceEpoch,
          closeTo(expected.millisecondsSinceEpoch, 2));
      expect(subscription.isClosed, isTrue);
    });
    test('scheduleRelative', () {
      var actual = epoch;
      final duration = Duration(milliseconds: 10);
      final expected = scheduler.now.add(duration);
      final subscription = scheduler.scheduleRelative(duration, () {
        expect(actual, epoch);
        actual = scheduler.now;
      });
      expect(actual.millisecondsSinceEpoch,
          closeTo(expected.millisecondsSinceEpoch, 2));
      expect(subscription.isClosed, isTrue);
    });
    test('schedulePeriodic', () {
      final timestamps = <int>[];
      final subscriptions = <Subscription>[];
      final start = scheduler.now.millisecondsSinceEpoch;
      final subscription = scheduler
          .schedulePeriodic(Duration(milliseconds: 10), (subscription) {
        timestamps.add(scheduler.now.millisecondsSinceEpoch);
        subscriptions.add(subscription);
        if (timestamps.length == 5) {
          subscription.unsubscribe();
        }
      });
      expect(timestamps.length, 5);
      expect(subscriptions.length, 5);
      for (var i = 0, t = start + 10; i < 5; i++, t += 10) {
        expect(timestamps[i], closeTo(t, 2 * (i + 1)));
        expect(subscriptions[i], subscription);
      }
    });
  });
}
