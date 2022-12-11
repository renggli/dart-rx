import 'package:rx/core.dart';
import 'package:rx/events.dart';
import 'package:test/test.dart';

void main() {
  group('next', () {
    const event = Event<int>.next(42);
    test('testing', () {
      expect(event.isNext, isTrue);
      expect(event.isError, isFalse);
      expect(event.isComplete, isFalse);
    });
    test('value', () {
      expect(event.value, 42);
    });
    test('error', () {
      expect(() => event.error, throwsUnimplementedError);
      expect(() => event.stackTrace, throwsUnimplementedError);
    });
    test('observe', () {
      late final int seenValue;
      event.observe(Observer(
        next: (value) => seenValue = value,
        error: (error, stackTrace) => fail('unexpected error'),
        complete: () => fail('unexpected complete'),
      ));
      expect(seenValue, 42);
    });
    test('equals', () {
      expect(event, const Event.next(42));
      expect(event, isNot(const Event.next('Hello')));
    });
    test('hashCode', () {
      expect(event.hashCode, const Event.next(42).hashCode);
      expect(event.hashCode, isNot(const Event.next('Hello').hashCode));
    });
    test('toString', () {
      expect(event.toString(), startsWith('NextEvent<int>'));
    });
  });
  group('error', () {
    final eventError = UnimplementedError();
    final eventStackTrace = StackTrace.current;
    final event = Event<int>.error(eventError, eventStackTrace);
    test('testing', () {
      expect(event.isNext, isFalse);
      expect(event.isError, isTrue);
      expect(event.isComplete, isFalse);
    });
    test('value', () {
      expect(() => event.value, throwsUnimplementedError);
    });
    test('error', () {
      expect(event.error, eventError);
      expect(event.stackTrace, eventStackTrace);
    });
    test('observe', () {
      late final Object seenError;
      late final StackTrace seenStackTrace;
      event.observe(Observer(
        next: (value) => fail('unexpected next'),
        error: (error, stackTrace) {
          seenError = error;
          seenStackTrace = stackTrace;
        },
        complete: () => fail('unexpected complete'),
      ));
      expect(seenError, eventError);
      expect(seenStackTrace, eventStackTrace);
    });
    test('equals', () {
      expect(event, Event<String>.error(eventError, eventStackTrace));
      expect(event, isNot(Event<String>.error(Error(), StackTrace.empty)));
    });
    test('hashCode', () {
      expect(event.hashCode,
          Event<String>.error(eventError, eventStackTrace).hashCode);
      expect(event.hashCode,
          isNot(Event<String>.error(Error(), StackTrace.empty).hashCode));
    });
    test('toString', () {
      expect(event.toString(), startsWith('ErrorEvent<int>'));
    });
  });
  group('complete', () {
    const event = Event<int>.complete();
    test('testing', () {
      expect(event.isNext, isFalse);
      expect(event.isError, isFalse);
      expect(event.isComplete, isTrue);
    });
    test('value', () {
      expect(() => event.value, throwsUnimplementedError);
    });
    test('error', () {
      expect(() => event.error, throwsUnimplementedError);
      expect(() => event.stackTrace, throwsUnimplementedError);
    });
    test('observe', () {
      late final bool seenComplete;
      event.observe(Observer(
        next: (value) => fail('unexpected next'),
        error: (error, stackTrace) => fail('unexpected error'),
        complete: () => seenComplete = true,
      ));
      expect(seenComplete, isTrue);
    });
    test('equals', () {
      expect(event, const Event<int>.complete());
      expect(event, isNot(const Event<int>.next(42)));
    });
    test('hashCode', () {
      expect(event.hashCode, const Event<int>.complete().hashCode);
      expect(event.hashCode, isNot(const Event.next(42).hashCode));
    });
    test('toString', () {
      expect(event.toString(), startsWith('CompleteEvent<int>'));
    });
  });
  group('mapping', () {
    final error = Error();
    group('map0', () {
      test('next', () {
        final nextEvent = Event.map0(() => 42);
        expect(nextEvent.value, 42);
      });
      test('error', () {
        final errorEvent = Event.map0(() => throw error);
        expect(errorEvent.error, error);
      });
    });
    group('map1', () {
      test('next', () {
        final nextEvent = Event.map1((int x) => x, 42);
        expect(nextEvent.value, 42);
      });
      test('error', () {
        final errorEvent = Event.map1((int x) => throw error, 42);
        expect(errorEvent.error, error);
      });
    });
    group('map2', () {
      test('next', () {
        final nextEvent = Event.map2((int x, int y) => x + y, 40, 2);
        expect(nextEvent.value, 42);
      });
      test('error', () {
        final errorEvent = Event.map2((int x, int y) => throw error, 40, 2);
        expect(errorEvent.error, error);
      });
    });
  });
}
