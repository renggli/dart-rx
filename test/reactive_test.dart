import 'package:rx/core.dart';
import 'package:rx/reactive.dart';
import 'package:test/test.dart';

void main() {
  group('mutable', () {
    test('basic', () {
      final ref = Mutable(0);
      final log = <int>[];
      ref.subscribe(Observer.next(log.add));
      expect(log, isEmpty);
      ref.value = 1;
      expect(log, [1]);
    });
    test('sequence', () {
      final ref = Mutable(0);
      final log = <int>[];
      ref.subscribe(Observer.next(log.add));
      expect(log, isEmpty);
      ref.value = 1;
      ref.value = 2;
      ref.value = 3;
      expect(log, [1, 2, 3]);
    });
    test('unmodified', () {
      final ref = Mutable(0);
      final log = <int>[];
      ref.subscribe(Observer.next(log.add));
      expect(log, isEmpty);
      ref.value = 0;
      expect(log, isEmpty);
    });
  });
  group('computed', () {
    group('value', () {
      test('no dependencies', () {
        final ref = Computed(() => 42);
        expect(ref.value, 42);
      });
      test('single dependency', () {
        final dep = Mutable(1);
        final ref = Computed(() => dep.value);
        final log = <int>[];
        ref.subscribe(Observer.next(log.add));
        expect(ref.value, 1);
        dep.value = 2;
        expect(ref.value, 2);
        expect(log, [2]);
      });
      test('double dependency', () {
        final dep1 = Mutable('John'), dep2 = Mutable('Doe');
        final ref = Computed(() => '${dep1.value} ${dep2.value}');
        final log = <String>[];
        ref.subscribe(Observer.next(log.add));
        expect(ref.value, 'John Doe');
        dep1.value = 'Jane';
        dep2.value = 'Roe';
        expect(ref.value, 'Jane Roe');
        expect(log, ['Jane Doe', 'Jane Roe']);
      });
      test('linear dependency', () {
        final dep1 = Mutable(2), dep2 = Computed(() => dep1.value * dep1.value);
        final ref = Computed(() => dep2.value.toString());
        final log = <String>[];
        ref.subscribe(Observer.next(log.add));
        expect(ref.value, '4');
        dep1.value = 3;
        expect(ref.value, '9');
        expect(log, ['9']);
      });
      test('dynamic dependency', () {
        final depBool = Mutable(false);
        final depTrue = Mutable(1), depFalse = Mutable(2);
        final ref = Computed(
          () => depBool.value ? depTrue.value : depFalse.value,
        );
        final log = <int>[];
        ref.subscribe(Observer.next(log.add));
        expect(ref.value, 2);
        depBool.value = true;
        expect(ref.value, 1);
        expect(log, [1]);
      });
    });
    group('error', () {
      test('no dependencies', () {
        final ref = Computed(() => throw StateError('Failure'));
        expect(
          () => ref.value,
          throwsA(
            isA<UnhandledError>().having(
              (err) => err.error,
              'error',
              isA<StateError>().having(
                (err) => err.message,
                'message',
                'Failure',
              ),
            ),
          ),
        );
      });
      test('single dependency', () {
        final dep = Mutable(1);
        final ref = Computed(
          () => dep.value.isNegative ? throw StateError('Failure') : dep.value,
        );
        final log = <int>[];
        ref.subscribe(Observer.next(log.add));
        expect(ref.value, 1);
        dep.value = -1;
        expect(
          () => ref.value,
          throwsA(
            isA<UnhandledError>().having(
              (err) => err.error,
              'error',
              isA<StateError>().having(
                (err) => err.message,
                'message',
                'Failure',
              ),
            ),
          ),
        );
        dep.value = 2;
        expect(ref.value, 2);
        expect(log, [2]);
      });
    });
  });
}
