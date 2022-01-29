import 'dart:async';

import 'package:rx/core.dart';
import 'package:rx/operators.dart';
import 'package:rx/store.dart';
import 'package:rx/subjects.dart';
import 'package:test/test.dart';

void main() {
  group('base store', () {
    test('state', () {
      final store = Store<int>(0);
      expect(store.state, 0);
    });
    test('update', () {
      final store = Store<int>(0);
      expect(store.update((state) {
        expect(state, 0);
        return state + 1;
      }), 1);
    });
    test('simple observer', () {
      final log = <int>[];
      final store = Store<int>(0);
      store.subscribe(Observer.next(log.add));
      store.update((state) => state + 1);
      expect(log, [1]);
    });
    test('operator observer', () {
      final log = <String>[];
      final store = Store<int>(0);
      store.map((state) => state.toString()).subscribe(Observer.next(log.add));
      store.update((state) => state + 1);
      expect(log, ['1']);
    });
    test('disposed observer', () {
      final log = <int>[];
      final store = Store<int>(0);
      final listener = store.subscribe(Observer.next(log.add));
      listener.dispose();
      store.update((state) => state + 1);
      expect(log, []);
    });
  });
  group('validating store', () {
    test('read state during update', () {
      final store = Store<int>(0);
      store.update((state) {
        expect(() => store.state, throwsStateError);
        return state + 1;
      });
      expect(store.state, 1);
    });
    test('update during update', () {
      final store = Store<int>(0);
      store.update((state) {
        expect(() => store.update((state) => state + 1), throwsStateError);
        return state + 1;
      });
      expect(store.state, 1);
    });
  });
  group('addFuture', () {
    test('onValue', () async {
      final store = Store<List<String>>([]);
      final completer = Completer<int>();
      final future = store.addFuture(completer.future,
          onValue: (state, value) => [...state, 'Value: $value']);
      expect(store.state, []);
      completer.complete(42);
      await future;
      expect(store.state, ['Value: 42']);
    });
    test('onError', () async {
      final store = Store<List<String>>([]);
      final completer = Completer<int>();
      final future = store.addFuture(
        completer.future,
        onError: (state, error, stackTrace) => [...state, 'Error: $error'],
      );
      expect(store.state, []);
      completer.completeError(StateError('Hello'), StackTrace.empty);
      await future;
      expect(store.state, ['Error: Bad state: Hello']);
    });
  });
  group('addObservable', () {
    test('next', () {
      final store = Store<List<String>>([]);
      final subject = Subject<int>();
      store.addObservable(subject,
          next: (state, value) => [...state, 'Value: $value']);
      expect(store.state, []);
      subject
        ..next(42)
        ..next(43)
        ..complete();
      expect(store.state, ['Value: 42', 'Value: 43']);
    });
    test('error', () {
      final store = Store<List<String>>([]);
      final subject = Subject<int>();
      store.addObservable<int>(subject,
          error: (state, error, stackTrace) => [...state, 'Error: $error']);
      expect(store.state, []);
      subject
        ..next(42)
        ..error(StateError('Hello'), StackTrace.empty);
      expect(store.state, ['Error: Bad state: Hello']);
    });
    test('complete', () {
      final store = Store<List<String>>([]);
      final subject = Subject<int>();
      store.addObservable<int>(subject,
          complete: (state) => [...state, 'Complete']);
      expect(store.state, []);
      subject
        ..next(42)
        ..complete();
      expect(store.state, ['Complete']);
    });
  });
}
