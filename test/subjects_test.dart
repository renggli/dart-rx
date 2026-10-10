import 'package:checks/checks.dart' hide Subject;
import 'package:rx/core.dart';
import 'package:rx/subjects.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

void main() {
  group('subject', () {
    test('next', () {
      final subject = Subject<int>();
      late int seenValue;
      subject.subscribe(
        Observer(
          next: (value) => seenValue = value,
          error: (error, stackTrace) => fail('unexpected error'),
          complete: () => fail('unexpected complete'),
        ),
      );
      for (var i = 0; i < 10; i++) {
        subject.next(i);
        check(seenValue).equals(i);
      }
    });

    test('error', () {
      final subject = Subject<int>();
      final error = Error();
      final stackTrace = StackTrace.current;
      late final Object seenError;
      late final StackTrace seenStackTrace;
      subject.subscribe(
        Observer(
          next: (value) => fail('unexpected next'),
          error: (error, stackTrace) {
            seenError = error;
            seenStackTrace = stackTrace;
          },
          complete: () => fail('unexpected complete'),
        ),
      );
      subject.error(error, stackTrace);
      check(seenError).equals(error);
      check(seenStackTrace).equals(stackTrace);
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
      subject.subscribe(
        Observer(
          next: (value) => fail('unexpected next'),
          error: (error, stackTrace) {
            seenError = error;
            seenStackTrace = stackTrace;
          },
          complete: () => fail('unexpected complete'),
        ),
      );
      check(seenError).equals(error);
      check(seenStackTrace).equals(stackTrace);
    });

    test('complete', () {
      final subject = Subject<int>();
      late final bool seenComplete;
      subject.subscribe(
        Observer(
          next: (value) => fail('unexpected next'),
          error: (error, stackTrace) => fail('unexpected error'),
          complete: () => seenComplete = true,
        ),
      );
      subject.complete();
      check(seenComplete).isTrue();
      subject.next(42);
      subject.error(Error(), StackTrace.current);
      subject.complete();
    });

    test('subscribe to complete', () {
      final subject = Subject<int>();
      late final bool seenComplete;
      subject.complete();
      subject.subscribe(
        Observer(
          next: (value) => fail('unexpected next'),
          error: (error, stackTrace) => fail('unexpected error'),
          complete: () => seenComplete = true,
        ),
      );
      check(seenComplete).isTrue();
    });

    test('disposed', () {
      final subject = Subject<int>();
      check(subject.isDisposed).isFalse();
      subject.dispose();
      check(subject.isDisposed).isTrue();
      check(() => subject.next(42)).throwsDisposedError();
      check(() => subject.error(Error(), StackTrace.empty))
          .throwsDisposedError();
      check(subject.complete).throwsDisposedError();
      check(() => subject.subscribe(Observer())).throwsDisposedError();
    });

    test('isObserved', () {
      final subject = Subject<int>();
      check(subject.isObserved).isFalse();
      final subscription = subject.subscribe(Observer());
      check(subject.isObserved).isTrue();
      subscription.dispose();
      check(subject.isObserved).isFalse();
    });
  });

  group('behavior', () {
    test('value', () {
      final subject = BehaviorSubject<int>(42);
      check(subject.value).equals(42);
      subject.next(43);
      check(subject.value).equals(43);
    });
  });
}
