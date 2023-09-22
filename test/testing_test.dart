import 'package:rx/events.dart';
import 'package:rx/schedulers.dart';
import 'package:rx/testing.dart';
import 'package:test/test.dart';

void main() {
  group('marbles', () {
    void expectParse<T>(String marbles, List<TestEvent<T>> events,
        {Map<String, T> values = const {},
        Object error = 'Error',
        bool toMarbles = true}) {
      final result = TestEventSequence<T>.fromString(marbles,
          values: values, error: error);
      expect(result.events, events);
      if (toMarbles) {
        expect(result.toMarbles(), marbles);
        expect(result.toString(), 'TestEventSequence<$T>{$marbles}');
      }
      final other = TestEventSequence<T>.fromString(marbles,
          values: values, error: error);
      expect(result, other);
      expect(result.hashCode, other.hashCode);
    }

    test('series of values', () {
      expectParse('-------a---b', const [
        WrappedEvent(7, Event.next('a')),
        WrappedEvent(11, Event.next('b')),
      ]);
    });
    test('series of values with custom mapping', () {
      expectParse('-------a---b', const [
        WrappedEvent(7, Event.next(1)),
        WrappedEvent(11, Event.next(2)),
      ], values: {
        'a': 1,
        'b': 2
      });
    });
    test('inferred character mapping', () {
      final result = TestEventSequence(const [
        WrappedEvent(1, Event.next(1)),
        WrappedEvent(3, Event.next(2)),
        WrappedEvent(5, Event.next(1)),
      ]);
      expect(result.toMarbles(), '-a-b-a');
    });
    test('inferred string character mapping', () {
      final result = TestEventSequence(const [
        WrappedEvent(1, Event.next('x')),
        WrappedEvent(3, Event.next('yy')),
        WrappedEvent(5, Event.next('x')),
      ]);
      expect(result.toMarbles(), '-x-a-x');
    });
    test('series of values with completion', () {
      expectParse<String>('-------a---b---|', const [
        WrappedEvent(7, Event.next('a')),
        WrappedEvent(11, Event.next('b')),
        WrappedEvent(15, Event.complete()),
      ]);
    });
    test('series of values with error', () {
      expectParse<String>('-------a---b---#', [
        const WrappedEvent(7, Event.next('a')),
        const WrappedEvent(11, Event.next('b')),
        WrappedEvent(15, Event.error('Error', StackTrace.current)),
      ]);
    });
    test('series of values with custom error', () {
      final error = ArgumentError('Custom error');
      expectParse<String>(
          '-------a---b---#',
          [
            const WrappedEvent(7, Event.next('a')),
            const WrappedEvent(11, Event.next('b')),
            WrappedEvent(15, Event.error(error, StackTrace.current)),
          ],
          error: error);
    });
    test('subscription and unsubscription', () {
      const subscribe = SubscribeEvent<String>(3);
      const unsubscribe = UnsubscribeEvent<String>(7);
      expectParse<String>('---^---!', const [subscribe, unsubscribe]);
      expect(subscribe.toString(), startsWith('SubscribeEvent<String>'));
      expect(unsubscribe.toString(), startsWith('UnsubscribeEvent<String>'));
      expect(subscribe, isNot(unsubscribe));
      expect(subscribe.hashCode, isNot(unsubscribe.hashCode));
    });
    test('invalid subscription and unsubscription', () {
      expect(() => TestEventSequence<String>.fromString('^^'),
          throwsArgumentError);
      expect(() => TestEventSequence<String>.fromString('!!'),
          throwsArgumentError);
    });
    test('grouped values', () {
      expectParse('---(abc)', const [
        WrappedEvent(3, Event.next('a')),
        WrappedEvent(3, Event.next('b')),
        WrappedEvent(3, Event.next('c')),
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
          const [
            WrappedEvent(3, Event.next('a')),
            WrappedEvent(7, Event.next('b')),
            WrappedEvent(11, Event.complete()),
          ],
          toMarbles: false);
    });
  });
  group('scheduler', () {
    final scheduler = TestScheduler();
    setUp(scheduler.setUp);
    tearDown(scheduler.tearDown);

    test('lifecycle', () {
      expect(scheduler.setUp, throwsStateError);
      scheduler.tearDown();
      expect(scheduler.tearDown, throwsStateError);
      scheduler.setUp();
    });
    group('cold observable', () {
      test('default', () {
        final observable = scheduler.cold<String>('ab(cd)|');
        expect(observable.toString(), 'ColdObservable<String>{ab(cd)|}');
        expect(observable, scheduler.isObservable<String>('ab(cd)|'));
        expect(observable, scheduler.isObservable<String>('ab(cd)|'));
        expect(scheduler.observables, [observable]);
        expect(scheduler.subscribers, hasLength(2));
        final firstSubscriber = scheduler.subscribers.first;
        expect(firstSubscriber.isDisposed, isTrue);
        expect(firstSubscriber.subscriptionTimestamp,
            scheduler.now.subtract(scheduler.stepDuration * 6));
        expect(firstSubscriber.unsubscriptionTimestamp,
            scheduler.now.subtract(scheduler.stepDuration * 3));
        final secondSubscriber = scheduler.subscribers.last;
        expect(secondSubscriber.isDisposed, isTrue);
        expect(secondSubscriber.subscriptionTimestamp,
            scheduler.now.subtract(scheduler.stepDuration * 3));
        expect(secondSubscriber.unsubscriptionTimestamp, scheduler.now);
      });
      test('subscribe event not allowed', () {
        expect(() => scheduler.cold<String>('^'), throwsArgumentError);
      });
      test('unsubscribe event not allowed', () {
        expect(() => scheduler.cold<String>('!'), throwsArgumentError);
      });
      test('assertion outside of scheduler', () {
        defaultScheduler = null;
        expect(() => scheduler.isObservable<String>(''), throwsStateError);
      });
    });
    group('hot observable', () {
      test('default', () {
        final observable = scheduler.hot<String>('ab(cd)|');
        expect(observable.toString(), 'HotObservable<String>{ab(cd)|}');
        expect(observable, scheduler.isObservable<String>('ab(cd)|'));
        expect(observable, scheduler.isObservable<String>('|'));
        expect(scheduler.observables, [observable]);
        expect(scheduler.subscribers, hasLength(2));
        final firstSubscriber = scheduler.subscribers.first;
        expect(firstSubscriber.isDisposed, isTrue);
        expect(firstSubscriber.subscriptionTimestamp,
            scheduler.now.subtract(scheduler.stepDuration * 3));
        expect(firstSubscriber.unsubscriptionTimestamp, scheduler.now);
        final secondSubscriber = scheduler.subscribers.last;
        expect(secondSubscriber.isDisposed, isTrue);
        expect(secondSubscriber.subscriptionTimestamp, scheduler.now);
        expect(secondSubscriber.unsubscriptionTimestamp, scheduler.now);
      });
      test('unsubscribe event not allowed', () {
        expect(() => scheduler.hot<String>('!'), throwsArgumentError);
      });
      test('active subscriber', () {
        final observable = scheduler.hot<String>('ab');
        expect(observable, scheduler.isObservable<String>('ab'));
        expect(scheduler.observables, [observable]);
        expect(scheduler.subscribers, hasLength(1));
        final subscriber = scheduler.subscribers.first;
        expect(subscriber.isDisposed, isFalse);
        expect(subscriber.subscriptionTimestamp,
            scheduler.now.subtract(scheduler.stepDuration));
        expect(() => subscriber.unsubscriptionTimestamp, throwsStateError);
      });
    });
  });
}
