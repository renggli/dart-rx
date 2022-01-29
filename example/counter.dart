import 'dart:io';
import 'dart:math';

import 'package:rx/constructors.dart';
import 'package:rx/core.dart';
import 'package:rx/operators.dart';
import 'package:rx/store.dart';

void main() async {
  // Create a store with initial value 0.
  final store = Store<int>(0);

  // Add a listener that prints the state whenever changed.
  store
      .map((state) => 'Current value: $state')
      .subscribe(Observer.next(stdout.writeln));

  // Update the value every 10 seconds randomly.
  final randomValue = timer(period: Duration(seconds: 10))
      .map((_) => Random().nextInt(100) - 50);
  store.addReducer(randomValue, next: (int state, int value) => state + value);

  // Manual increment and decrement the value.
  stdin.lineMode = stdin.echoMode = false;
  final stream = stdin.asBroadcastStream();
  while (true) {
    final bytes = await stream.first;
    final chars = String.fromCharCodes(bytes);
    switch (chars) {
      case '+':
        store.update((state) => state + 1);
        break;
      case '-':
        store.update((state) => state - 1);
        break;
      default:
        exit(0);
    }
  }
}
