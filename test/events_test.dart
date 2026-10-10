import 'package:checks/checks.dart';
import 'package:rx/core.dart';
import 'package:rx/events.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

void main() {
  group('next', () {
    const event = Event<int>.next(42);
    test('testing', () {
      check(event)
        ..isNext.isTrue()
        ..isError.isFalse()
        ..isComplete.isFalse();
    });
    test('value', () {
      check(event).value.equals(42);
    });
    test('error', () {
      check(() => event.error).throws<UnimplementedError>();
      check(() => event.stackTrace).throws<UnimplementedError>();
    });
    test('observe', () {
      late final int seenValue;
      event.observe(
        Observer(
          next: (value) => seenValue = value,
          error: (error, stackTrace) => fail('unexpected error'),
          complete: () => fail('unexpected complete'),
        ),
      );
      check(seenValue).equals(42);
    });
    test('equals', () {
      check(event == const Event.next(42)).isTrue();
      // ignore: unrelated_type_equality_checks
      check(event == const Event.next('Hello')).isFalse();
    });
    test('hashCode', () {
      check(event.hashCode).equals(const Event.next(42).hashCode);
      check(event.hashCode != const Event.next('Hello').hashCode).isTrue();
    });
    test('toString', () {
      check(event.toString()).startsWith('NextEvent<int>');
    });
  });

  group('error', () {
    final eventError = UnimplementedError();
    final eventStackTrace = StackTrace.current;
    final event = Event<int>.error(eventError, eventStackTrace);
    test('testing', () {
      check(event)
        ..isNext.isFalse()
        ..isError.isTrue()
        ..isComplete.isFalse();
    });
    test('value', () {
      check(() => event.value).throws<UnimplementedError>();
    });
    test('error', () {
      check(event)
        ..error.equals(eventError)
        ..stackTrace.equals(eventStackTrace);
    });
    test('observe', () {
      late final Object seenError;
      late final StackTrace seenStackTrace;
      event.observe(
        Observer(
          next: (value) => fail('unexpected next'),
          error: (error, stackTrace) {
            seenError = error;
            seenStackTrace = stackTrace;
          },
          complete: () => fail('unexpected complete'),
        ),
      );
      check(seenError).equals(eventError);
      check(seenStackTrace).equals(eventStackTrace);
    });
    test('equals', () {
      // ignore: unrelated_type_equality_checks
      check(event == Event<String>.error(eventError, eventStackTrace)).isTrue();
      // ignore: unrelated_type_equality_checks
      check(event == Event<String>.error(Error(), StackTrace.empty)).isFalse();
    });
    test('hashCode', () {
      check(event.hashCode)
          .equals(Event<String>.error(eventError, eventStackTrace).hashCode);
      check(
        event.hashCode !=
            Event<String>.error(Error(), StackTrace.empty).hashCode,
      ).isTrue();
    });
    test('toString', () {
      check(event.toString()).startsWith('ErrorEvent<int>');
    });
  });

  group('complete', () {
    const event = Event<int>.complete();
    test('testing', () {
      check(event)
        ..isNext.isFalse()
        ..isError.isFalse()
        ..isComplete.isTrue();
    });
    test('value', () {
      check(() => event.value).throws<UnimplementedError>();
    });
    test('error', () {
      check(() => event.error).throws<UnimplementedError>();
      check(() => event.stackTrace).throws<UnimplementedError>();
    });
    test('observe', () {
      late final bool seenComplete;
      event.observe(
        Observer(
          next: (value) => fail('unexpected next'),
          error: (error, stackTrace) => fail('unexpected error'),
          complete: () => seenComplete = true,
        ),
      );
      check(seenComplete).isTrue();
    });
    test('equals', () {
      check(event == const Event<int>.complete()).isTrue();
      check(event == const Event<int>.next(42)).isFalse();
    });
    test('hashCode', () {
      check(event.hashCode).equals(const Event<int>.complete().hashCode);
      check(event.hashCode != const Event.next(42).hashCode).isTrue();
    });
    test('toString', () {
      check(event.toString()).startsWith('CompleteEvent<int>');
    });
  });

  group('mapping', () {
    final error = Error();
    group('map0', () {
      test('next', () {
        final nextEvent = Event.map0(() => 42);
        check(nextEvent).value.equals(42);
      });
      test('error', () {
        final errorEvent = Event.map0(() => throw error);
        check(errorEvent).error.equals(error);
      });
    });
    group('map1', () {
      test('next', () {
        final nextEvent = Event.map1((int x) => x, 42);
        check(nextEvent).value.equals(42);
      });
      test('error', () {
        final errorEvent = Event.map1((int x) => throw error, 42);
        check(errorEvent).error.equals(error);
      });
    });
    group('map2', () {
      test('next', () {
        final nextEvent = Event.map2((int x, int y) => x + y, 40, 2);
        check(nextEvent).value.equals(42);
      });
      test('error', () {
        final errorEvent = Event.map2((int x, int y) => throw error, 40, 2);
        check(errorEvent).error.equals(error);
      });
    });
  });
}
