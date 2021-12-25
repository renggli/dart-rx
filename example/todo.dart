import 'dart:io';
import 'dart:math';

import 'package:rx/store.dart';

/// Struct of the application state.
class State {
  /// Default constructor of the application state.
  State({List<String>? items, int? index})
      : items = items ?? [],
        index = max(0, min((items ?? []).length - 1, index ?? 0));

  /// Copies and modifies the application state.
  State copy({List<String>? items, int? index}) =>
      State(items: items ?? this.items, index: index ?? this.index);

  /// The string items in this list.
  final List<String> items;

  /// The active item in the list.
  final int index;
}

/// Standard filename to store todo lists.
final file = File('example/todo.txt');

/// Reads the initial state from storage file.
State readState() {
  final state = State();
  if (file.existsSync()) {
    state.items.addAll(file
        .readAsLinesSync()
        .map((each) => each.trim())
        .where((each) => each.isNotEmpty));
  }
  return state;
}

/// Writes the state to the todo storage file.
void writeState(State state) {
  file.writeAsStringSync(state.items.join('\n'));
}

/// The store of the application state.
final store = Store<State>(readState())..addListener(writeState);

void main() {
  // Test terminal capabilities.
  if (!stdout.hasTerminal || !stdout.supportsAnsiEscapes) {
    stderr.writeln('Unsupported terminal window.');
    exit(1);
  }

  // Application loop.
  while (true) {
    // Print the current state to stdout.
    stdout.write('\x1b[2J\x1b[H');
    if (store.state.items.isNotEmpty) {
      for (var i = 0; i < store.state.items.length; i++) {
        stdout.writeln(
            '${store.state.index == i ? '>' : ' '} ${store.state.items[i]}');
      }
    } else {
      stdout.writeln('(no items)');
    }
    stdout.writeln();
    stdout.writeln('[u]p [d]own [a]dd [r]emove [q]uit');

    // Read the command from the input.
    stdin.lineMode = stdin.echoMode = false;
    final command = String.fromCharCode(stdin.readByteSync());
    stdin.lineMode = stdin.echoMode = true;

    // Dispatch to the right command.
    switch (command) {
      case 'u':
        store.update((state) => state.copy(index: state.index - 1));
        break;
      case 'd':
        store.update((state) => state.copy(index: state.index + 1));
        break;
      case 'a':
        stdout.write('Add: ');
        final item = stdin.readLineSync();
        if (item != null) {
          store.update((state) =>
              state.copy(items: [...state.items]..insert(state.index, item)));
        }
        break;
      case 'r':
        if (store.state.items.isNotEmpty) {
          store.update((state) =>
              state.copy(items: [...state.items]..removeAt(state.index)));
        }
        break;
      case 'q':
        exit(0);
    }
  }
}
