import 'package:checks/checks.dart';
import 'package:rx/core.dart';
import 'package:rx/reactive.dart';
import 'package:test/scaffolding.dart';

import 'test_utils.dart';

void main() {
  group('mutable', () {
    test('basic', () {
      final ref = Mutable(0);
      final log = <int>[];
      ref.subscribe(Observer.next(log.add));
      check(log).isEmpty();
      ref.value = 1;
      check(log).deepEquals([1]);
    });

    test('sequence', () {
      final ref = Mutable(0);
      final log = <int>[];
      ref.subscribe(Observer.next(log.add));
      check(log).isEmpty();
      ref.value = 1;
      ref.value = 2;
      ref.value = 3;
      check(log).deepEquals([1, 2, 3]);
    });

    test('unmodified', () {
      final ref = Mutable(0);
      final log = <int>[];
      ref.subscribe(Observer.next(log.add));
      check(log).isEmpty();
      ref.value = 0;
      check(log).isEmpty();
    });
  });

  group('computed', () {
    group('value', () {
      test('no dependencies', () {
        final ref = Computed(() => 42);
        check(ref.value).equals(42);
      });

      test('single dependency', () {
        final dep = Mutable(1);
        final ref = Computed(() => dep.value);
        final log = <int>[];
        ref.subscribe(Observer.next(log.add));
        check(ref.value).equals(1);
        dep.value = 2;
        check(ref.value).equals(2);
        check(log).deepEquals([2]);
      });

      test('double dependency', () {
        final dep1 = Mutable('John'), dep2 = Mutable('Doe');
        final ref = Computed(() => '${dep1.value} ${dep2.value}');
        final log = <String>[];
        ref.subscribe(Observer.next(log.add));
        check(ref.value).equals('John Doe');
        dep1.value = 'Jane';
        dep2.value = 'Roe';
        check(ref.value).equals('Jane Roe');
        check(log).deepEquals(['Jane Doe', 'Jane Roe']);
      });

      test('linear dependency', () {
        final dep1 = Mutable(2), dep2 = Computed(() => dep1.value * dep1.value);
        final ref = Computed(() => dep2.value.toString());
        final log = <String>[];
        ref.subscribe(Observer.next(log.add));
        check(ref.value).equals('4');
        dep1.value = 3;
        check(ref.value).equals('9');
        check(log).deepEquals(['9']);
      });

      test('dynamic dependency', () {
        final depBool = Mutable(false);
        final depTrue = Mutable(1), depFalse = Mutable(2);
        final ref = Computed(
          () => depBool.value ? depTrue.value : depFalse.value,
        );
        final log = <int>[];
        ref.subscribe(Observer.next(log.add));
        check(ref.value).equals(2);
        depBool.value = true;
        check(ref.value).equals(1);
        check(log).deepEquals([1]);
      });
    });

    group('error', () {
      test('no dependencies', () {
        final ref = Computed(() => throw StateError('Failure'));
        check(() => ref.value)
            .throws<UnhandledError>()
            .error
            .isA<StateError>()
            .has((err) => err.message, 'message')
            .equals('Failure');
      });

      test('single dependency', () {
        final dep = Mutable(1);
        final ref = Computed(
          () => dep.value.isNegative ? throw StateError('Failure') : dep.value,
        );
        final log = <int>[];
        ref.subscribe(Observer.next(log.add));
        check(ref.value).equals(1);
        dep.value = -1;
        check(() => ref.value)
            .throws<UnhandledError>()
            .error
            .isA<StateError>()
            .has((err) => err.message, 'message')
            .equals('Failure');
        dep.value = 2;
        check(ref.value).equals(2);
        check(log).deepEquals([2]);
      });
    });
  });
}
