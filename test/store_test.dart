import 'package:rx/store.dart';
import 'package:rx/subjects.dart';
import 'package:test/test.dart';

void main() {
  group('basic', () {
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
    test('update & notify', () {
      final log = <int>[];
      final store = Store<int>(0);
      store.addListener(log.add);
      store.update((state) => state + 1);
      expect(log, [1]);
    });
    test('disposed listener', () {
      final log = <int>[];
      final store = Store<int>(0);
      final listener = store.addListener(log.add);
      listener.dispose();
      store.update((state) => state + 1);
      expect(log, []);
    });
    test('reducer next', () {
      final store = Store<List<String>>([]);
      final subject = Subject<int>();
      store.addReducer<int>(subject,
          next: (state, value) => [...state, 'Value: $value']);
      expect(store.state, []);
      subject
        ..next(42)
        ..next(43)
        ..complete();
      expect(store.state, ['Value: 42', 'Value: 43']);
    });
    test('reducer error', () {
      final store = Store<List<String>>([]);
      final subject = Subject<int>();
      store.addReducer<int>(
        subject,
        error: (state, error, stackTrace) => [...state, 'Error: $error'],
      );
      expect(store.state, []);
      subject
        ..next(42)
        ..error(StateError('Hello'), StackTrace.empty);
      expect(store.state, ['Error: Bad state: Hello']);
    });
    test('reducer complete', () {
      final store = Store<List<String>>([]);
      final subject = Subject<int>();
      store.addReducer<int>(
        subject,
        complete: (state) => [...state, 'Complete'],
      );
      expect(store.state, []);
      subject
        ..next(42)
        ..complete();
      expect(store.state, ['Complete']);
    });
  });
  group('basic', () {
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
}
