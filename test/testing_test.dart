import 'package:checks/checks.dart';
import 'package:rx/events.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/testing.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

void main() {
  group('marbles', () {
    void checkParse<T>(
      String marbles,
      List<TestEvent<T>> events, {
      Map<String, T> values = const {},
      Object error = 'Error',
      bool toMarbles = true,
    }) {
      final result = TestEventSequence<T>.fromString(
        marbles,
        values: values,
        error: error,
      );
      check(result.events).deepEquals(events);
      if (toMarbles) {
        check(result.toMarbles()).equals(marbles);
        check(result.toString()).equals('TestEventSequence<$T>{$marbles}');
      }
      final other = TestEventSequence<T>.fromString(
        marbles,
        values: values,
        error: error,
      );
      check(result == other).isTrue();
      check(result.hashCode).equals(other.hashCode);
    }

    test('series of values', () {
      checkParse('-------a---b', const <TestEvent<String>>[
        WrappedEvent(7, Event.next('a')),
        WrappedEvent(11, Event.next('b')),
      ]);
    });

    test('series of values with custom mapping', () {
      checkParse(
        '-------a---b',
        const <TestEvent<int>>[
          WrappedEvent(7, Event.next(1)),
          WrappedEvent(11, Event.next(2)),
        ],
        values: {'a': 1, 'b': 2},
      );
    });

    test('inferred character mapping', () {
      final result = TestEventSequence(const <TestEvent<int>>[
        WrappedEvent(1, Event.next(1)),
        WrappedEvent(3, Event.next(2)),
        WrappedEvent(5, Event.next(1)),
      ]);
      check(result.toMarbles()).equals('-a-b-a');
    });

    test('inferred string character mapping', () {
      final result = TestEventSequence(const <TestEvent<String>>[
        WrappedEvent(1, Event.next('x')),
        WrappedEvent(3, Event.next('yy')),
        WrappedEvent(5, Event.next('x')),
      ]);
      check(result.toMarbles()).equals('-x-a-x');
    });

    test('series of values with completion', () {
      checkParse<String>('-------a---b---|', const <TestEvent<String>>[
        WrappedEvent(7, Event.next('a')),
        WrappedEvent(11, Event.next('b')),
        WrappedEvent(15, Event.complete()),
      ]);
    });

    test('series of values with error', () {
      checkParse<String>('-------a---b---#', <TestEvent<String>>[
        const WrappedEvent(7, Event.next('a')),
        const WrappedEvent(11, Event.next('b')),
        WrappedEvent(15, Event.error('Error', StackTrace.current)),
      ]);
    });

    test('series of values with custom error', () {
      final error = ArgumentError('Custom error');
      checkParse<String>('-------a---b---#', <TestEvent<String>>[
        const WrappedEvent(7, Event.next('a')),
        const WrappedEvent(11, Event.next('b')),
        WrappedEvent(15, Event.error(error, StackTrace.current)),
      ], error: error);
    });

    test('subscription and unsubscription', () {
      const subscribe = SubscribeEvent<String>(3);
      const unsubscribe = UnsubscribeEvent<String>(7);
      checkParse<String>('---^---!', const <TestEvent<String>>[
        subscribe,
        unsubscribe,
      ]);
      check(subscribe.toString()).startsWith('SubscribeEvent<String>');
      check(unsubscribe.toString()).startsWith('UnsubscribeEvent<String>');
      // ignore: unrelated_type_equality_checks
      check(subscribe == unsubscribe).isFalse();
      check(subscribe.hashCode != unsubscribe.hashCode).isTrue();
    });

    test('invalid subscription and unsubscription', () {
      check(() => TestEventSequence<String>.fromString('^^'))
          .throws<ArgumentError>();
      check(() => TestEventSequence<String>.fromString('!!'))
          .throws<ArgumentError>();
    });

    test('grouped values', () {
      checkParse('---(abc)', const <TestEvent<String>>[
        WrappedEvent(3, Event.next('a')),
        WrappedEvent(3, Event.next('b')),
        WrappedEvent(3, Event.next('c')),
      ]);
    });

    test('invalid grouping', () {
      check(() => TestEventSequence<String>.fromString('(('))
          .throws<ArgumentError>();
      check(() => TestEventSequence<String>.fromString('(a'))
          .throws<ArgumentError>();
      check(() => TestEventSequence<String>.fromString(')a'))
          .throws<ArgumentError>();
    });

    test('ignores whitespaces when parsing', () {
      checkParse<String>('--- a\t---b---\n|', const <TestEvent<String>>[
        WrappedEvent(3, Event.next('a')),
        WrappedEvent(7, Event.next('b')),
        WrappedEvent(11, Event.complete()),
      ], toMarbles: false);
    });
  });

  group('scheduler', () {
    final scheduler = TestScheduler();
    setUp(scheduler.setUp);
    tearDown(scheduler.tearDown);

    test('lifecycle', () {
      check(scheduler.setUp).throws<StateError>();
      scheduler.tearDown();
      check(scheduler.tearDown).throws<StateError>();
      scheduler.setUp();
    });

    group('cold observable', () {
      test('default', () {
        final observable = scheduler.cold<String>('ab(cd)|');
        check(observable.toString()).equals('ColdObservable<String>{ab(cd)|}');
        check(observable).matches(scheduler.isObservable<String>('ab(cd)|'));
        check(observable).matches(scheduler.isObservable<String>('ab(cd)|'));
        check(scheduler.observables).deepEquals([observable]);
        check(scheduler.subscribers).length.equals(2);
        final firstSubscriber = scheduler.subscribers.first;
        check(firstSubscriber.isDisposed).isTrue();
        check(firstSubscriber.subscriptionTimestamp)
            .equals(scheduler.now.subtract(scheduler.stepDuration * 6));
        check(firstSubscriber.unsubscriptionTimestamp)
            .equals(scheduler.now.subtract(scheduler.stepDuration * 3));
        final secondSubscriber = scheduler.subscribers.last;
        check(secondSubscriber.isDisposed).isTrue();
        check(secondSubscriber.subscriptionTimestamp)
            .equals(scheduler.now.subtract(scheduler.stepDuration * 3));
        check(secondSubscriber.unsubscriptionTimestamp).equals(scheduler.now);
      });

      test('subscribe event not allowed', () {
        check(() => scheduler.cold<String>('^')).throws<ArgumentError>();
      });

      test('unsubscribe event not allowed', () {
        check(() => scheduler.cold<String>('!')).throws<ArgumentError>();
      });

      test('assertion outside of scheduler', () {
        defaultScheduler = null;
        check(() => scheduler.isObservable<String>('')).throws<StateError>();
      });
    });

    group('hot observable', () {
      test('default', () {
        final observable = scheduler.hot<String>('ab(cd)|');
        check(observable.toString()).equals('HotObservable<String>{ab(cd)|}');
        check(observable).matches(scheduler.isObservable<String>('ab(cd)|'));
        check(observable).matches(scheduler.isObservable<String>('|'));
        check(scheduler.observables).deepEquals([observable]);
        check(scheduler.subscribers).length.equals(2);
        final firstSubscriber = scheduler.subscribers.first;
        check(firstSubscriber.isDisposed).isTrue();
        check(firstSubscriber.subscriptionTimestamp)
            .equals(scheduler.now.subtract(scheduler.stepDuration * 3));
        check(firstSubscriber.unsubscriptionTimestamp).equals(scheduler.now);
        final secondSubscriber = scheduler.subscribers.last;
        check(secondSubscriber.isDisposed).isTrue();
        check(secondSubscriber.subscriptionTimestamp).equals(scheduler.now);
        check(secondSubscriber.unsubscriptionTimestamp).equals(scheduler.now);
      });

      test('unsubscribe event not allowed', () {
        check(() => scheduler.hot<String>('!')).throws<ArgumentError>();
      });

      test('active subscriber', () {
        final observable = scheduler.hot<String>('ab');
        check(observable).matches(scheduler.isObservable<String>('ab'));
        check(scheduler.observables).deepEquals([observable]);
        check(scheduler.subscribers).length.equals(1);
        final subscriber = scheduler.subscribers.first;
        check(subscriber.isDisposed).isFalse();
        check(subscriber.subscriptionTimestamp)
            .equals(scheduler.now.subtract(scheduler.stepDuration));
        check(() => subscriber.unsubscriptionTimestamp).throws<StateError>();
      });
    });
  });
}
