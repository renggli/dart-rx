import 'dart:async';

import 'package:rx/core.dart';
import 'package:rx/operators.dart';
import 'package:rx/store.dart';
import 'package:rx/subjects.dart';
import 'package:test/test.dart';

void sharedStoreTests(Store<T> Function<T>(T initialValue) createStore) {
  test('state', () {
    final store = createStore<int>(0);
    expect(store.state, 0);
  });
  test('single update', () {
    final store = createStore<int>(0);
    expect(store.update((state) {
      expect(state, 0);
      return state + 1;
    }), 1);
  });
  test('multiple updates', () {
    final store = createStore<int>(0);
    for (var i = 0; i <= 10; i++) {
      store.update((state) => state + i);
    }
    expect(store.state, 55);
  });
  test('simple observer', () {
    final log = <int>[];
    final store = createStore<int>(0);
    store.subscribe(Observer.next(log.add));
    store.update((state) => state + 1);
    expect(log, [1]);
  });
  test('operator observer', () {
    final log = <String>[];
    final store = createStore<int>(0);
    store.map((state) => state.toString()).subscribe(Observer.next(log.add));
    store.update((state) => state + 1);
    expect(log, ['1']);
  });
  test('disposed observer', () {
    final log = <int>[];
    final store = createStore<int>(0);
    final listener = store.subscribe(Observer.next(log.add));
    listener.dispose();
    store.update((state) => state + 1);
    expect(log, isEmpty);
  });
  test('multiple observer', () {
    final log = <String>[];
    final store = createStore<int>(0);
    store.subscribe(Observer.next((value) => log.add('a:$value')));
    store.subscribe(Observer.next((value) => log.add('b:$value')));
    store.update((state) => state + 1);
    store.update((state) => state + 3);
    expect(log, ['a:1', 'b:1', 'a:4', 'b:4']);
  });
}

void main() {
  group('DefaultStore', () {
    DefaultStore<T> createStore<T>(T initialValue) =>
        DefaultStore<T>(initialValue);
    sharedStoreTests(createStore);
  });
  group('ValidatingStore', () {
    ValidatingStore<T> createStore<T>(T initialValue) =>
        ValidatingStore(DefaultStore<T>(initialValue));
    sharedStoreTests(createStore);
    test('read state during update', () {
      final store = createStore<int>(0);
      store.update((state) {
        expect(() => store.state, throwsStateError);
        return state + 1;
      });
      expect(store.state, 1);
    });
    test('update during update', () {
      final store = createStore<int>(0);
      store.update((state) {
        expect(() => store.update((state) => state + 1), throwsStateError);
        return state + 1;
      });
      expect(store.state, 1);
    });
  });
  group('HistoryStore', () {
    HistoryStore<T> createStore<T>(T initialValue) =>
        HistoryStore(DefaultStore<T>(initialValue));
    sharedStoreTests(createStore);
    test('initial state', () {
      final store = createStore<int>(0);
      expect(store.canUndo, isFalse);
      expect(store.past, isEmpty);
      expect(store.canRedo, isFalse);
      expect(store.future, isEmpty);
    });
    test('after update', () {
      final store = createStore<int>(0);
      store.update((state) => state + 1);
      expect(store.canUndo, isTrue);
      expect(store.past, [0]);
      expect(store.state, 1);
      expect(store.canRedo, isFalse);
      expect(store.future, isEmpty);
    });
    test('after undo', () {
      final store = createStore<int>(0);
      store.update((state) => state + 1);
      store.undo();
      expect(store.canUndo, isFalse);
      expect(store.past, isEmpty);
      expect(store.state, 0);
      expect(store.canRedo, isTrue);
      expect(store.future, [1]);
    });
    test('after redo', () {
      final store = createStore<int>(0);
      store.update((state) => state + 1);
      store.undo();
      store.redo();
      expect(store.canUndo, isTrue);
      expect(store.past, [0]);
      expect(store.state, 1);
      expect(store.canRedo, isFalse);
      expect(store.future, isEmpty);
    });
    test('limit history', () {
      final store = HistoryStore(DefaultStore<int>(0), limit: 5);
      for (var i = 0; i <= 10; i++) {
        store.update((state) => i);
      }
      expect(store.past, [5, 6, 7, 8, 9]);
    });
  });
  group('addFuture', () {
    test('onValue', () async {
      final store = Store<List<String>>([]);
      final completer = Completer<int>();
      final future = store.addFuture(completer.future,
          onValue: (state, value) => [...state, 'Value: $value']);
      expect(store.state, isEmpty);
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
      expect(store.state, isEmpty);
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
      expect(store.state, isEmpty);
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
      expect(store.state, isEmpty);
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
      expect(store.state, isEmpty);
      subject
        ..next(42)
        ..complete();
      expect(store.state, ['Complete']);
    });
  });
  group('addStream', () {
    test('next', () async {
      final store = Store<List<String>>([]);
      final controller = StreamController<int>();
      store.addStream(controller.stream,
          onData: (state, value) => [...state, 'Value: $value']);
      expect(store.state, isEmpty);
      controller
        ..add(42)
        ..add(43)
        ..close();
      await controller.done;
      expect(store.state, ['Value: 42', 'Value: 43']);
    });
    test('error', () async {
      final store = Store<List<String>>([]);
      final controller = StreamController<int>();
      store.addStream(controller.stream,
          onError: (state, error, stackTrace) => [...state, 'Error: $error']);
      expect(store.state, isEmpty);
      controller
        ..add(42)
        ..addError(StateError('Hello'), StackTrace.empty)
        ..close();
      await controller.done;
      expect(store.state, ['Error: Bad state: Hello']);
    });
    test('complete', () async {
      final store = Store<List<String>>([]);
      final controller = StreamController<int>();
      store.addStream(controller.stream,
          onDone: (state) => [...state, 'Complete']);
      expect(store.state, isEmpty);
      controller
        ..add(42)
        ..close();
      await controller.done;
      expect(store.state, ['Complete']);
    });
  });
}
