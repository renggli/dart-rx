import 'dart:io';
import 'dart:math';

import 'package:rx/constructors.dart';
import 'package:rx/converters.dart';
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
  final randomValue = timer(period: const Duration(seconds: 10))
      .map((_) => Random().nextInt(100) - 50);
  store.addObservable(randomValue,
      next: (int state, int value) => state + value);

  // Display help text.
  stdout.writeln('Use [+] to increment and [-] to decrement the counter.');
  stdout.writeln('Every 10sec the counter is updated randomly.');
  stdout.writeln();

  // Open an asynchronous reader.
  stdin.lineMode = stdin.echoMode = false;
  stdin
      .toObservable()
      .finalize(() => stdin.lineMode = stdin.echoMode = false)
      .subscribe(Observer.next((bytes) {
    switch (String.fromCharCodes(bytes)) {
      case '+':
        store.update((state) => state + 1);
      case '-':
        store.update((state) => state - 1);
    }
  }));
}
