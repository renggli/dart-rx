library rx.test.all_test;

import 'package:test/test.dart';

import 'constructors_test.dart' as constructors_test;
import 'converters_test.dart' as converters_test;
import 'disposables_test.dart' as disposables_test;
import 'operators_test.dart' as operators_test;
import 'schedulers_test.dart' as schedulers_test;
import 'testing_test.dart' as testing_test;

void main() {
  group('constructors', constructors_test.main);
  group('converters', converters_test.main);
  group('disposables', disposables_test.main);
  group('operators', operators_test.main);
  group('schedulers', schedulers_test.main);
  group('testing', testing_test.main);
}
