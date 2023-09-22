import 'package:rx/core.dart';
import 'package:rx/subjects.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('subject', () {
    test('next', () {
      final subject = Subject<int>();
      late int seenValue;
      subject.subscribe(Observer(
        next: (value) => seenValue = value,
        error: (error, stackTrace) => fail('unexpected error'),
        complete: () => fail('unexpected complete'),
      ));
      for (var i = 0; i < 10; i++) {
        subject.next(i);
        expect(seenValue, i);
      }
    });
    test('error', () {
      final subject = Subject<int>();
      final error = Error();
      final stackTrace = StackTrace.current;
      late final Object seenError;
      late final StackTrace seenStackTrace;
      subject.subscribe(Observer(
        next: (value) => fail('unexpected next'),
        error: (error, stackTrace) {
          seenError = error;
          seenStackTrace = stackTrace;
        },
        complete: () => fail('unexpected complete'),
      ));
      subject.error(error, stackTrace);
      expect(seenError, error);
      expect(seenStackTrace, stackTrace);
      subject.next(42);
      subject.error(error, stackTrace);
      subject.complete();
    });
    test('subscribe to error', () {
      final subject = Subject<int>();
      final error = Error();
      final stackTrace = StackTrace.current;
      late final Object seenError;
      late final StackTrace seenStackTrace;
      subject.error(error, stackTrace);
      subject.subscribe(Observer(
        next: (value) => fail('unexpected next'),
        error: (error, stackTrace) {
          seenError = error;
          seenStackTrace = stackTrace;
        },
        complete: () => fail('unexpected complete'),
      ));
      expect(seenError, error);
      expect(seenStackTrace, stackTrace);
    });
    test('complete', () {
      final subject = Subject<int>();
      late final bool seenComplete;
      subject.subscribe(Observer(
        next: (value) => fail('unexpected next'),
        error: (error, stackTrace) => fail('unexpected error'),
        complete: () => seenComplete = true,
      ));
      subject.complete();
      expect(seenComplete, isTrue);
      subject.next(42);
      subject.error(Error(), StackTrace.current);
      subject.complete();
    });
    test('subscribe to complete', () {
      final subject = Subject<int>();
      late final bool seenComplete;
      subject.complete();
      subject.subscribe(Observer(
        next: (value) => fail('unexpected next'),
        error: (error, stackTrace) => fail('unexpected error'),
        complete: () => seenComplete = true,
      ));
      expect(seenComplete, isTrue);
    });
    test('disposed', () {
      final subject = Subject<int>();
      expect(subject.isDisposed, isFalse);
      subject.dispose();
      expect(subject.isDisposed, isTrue);
      expect(() => subject.next(42), throwsDisposedError);
      expect(
          () => subject.error(Error(), StackTrace.empty), throwsDisposedError);
      expect(subject.complete, throwsDisposedError);
      expect(() => subject.subscribe(Observer()), throwsDisposedError);
    });
    test('isObserved', () {
      final subject = Subject<int>();
      expect(subject.isObserved, isFalse);
      final subscription = subject.subscribe(Observer());
      expect(subject.isObserved, isTrue);
      subscription.dispose();
      expect(subject.isObserved, isFalse);
    });
  });
  group('behavior', () {
    test('value', () {
      final subject = BehaviorSubject<int>(42);
      expect(subject.value, 42);
      subject.next(43);
      expect(subject.value, 43);
    });
  });
}
