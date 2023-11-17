import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:more/functional.dart';
import 'package:rx/core.dart';
import 'package:rx/store.dart';

/// Struct of the application state.
@immutable
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

/// Struct of all operations.
@immutable
class Operation {
  /// Default constructor of an operation
  Operation(this.key, this.label, this.action,
      {Predicate0? isEnabled, Predicate0? isMenu})
      : isEnabled = isEnabled ?? constantFunction0(true),
        isMenu = isMenu ?? constantFunction0(true);

  /// The key to be pressed to trigger the action.
  final String key;

  /// The label of the action.
  final String label;

  /// Predicate telling if the action can be triggered.
  final Predicate0 isEnabled;

  /// Predicate telling if the operation should show in the menu.
  final Predicate0 isMenu;

  /// The actual code executing the action.
  final Callback0 action;

  @override
  String toString() => '[$key] ${label.padRight(10)}';
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
final store = HistoryStore<State>(Store(readState()))
  ..subscribe(Observer.next(writeState));

/// The supported operations.
final operations = [
  Operation(
    'j',
    'Up',
    () => store.update((state) => state.copy(index: state.index - 1)),
    isEnabled: () => store.state.index > 0,
  ),
  Operation(
    'k',
    'Down',
    () => store.update((state) => state.copy(index: state.index + 1)),
    isEnabled: () => store.state.index < store.state.items.length - 1,
  ),
  Operation(
    'J',
    'Move Up',
    () => store.update((state) => state.copy(
        items: [...state.items]..swap(state.index, state.index - 1),
        index: state.index - 1)),
    isEnabled: () => store.state.index > 0,
    isMenu: constantFunction0(false),
  ),
  Operation(
    'K',
    'Move Down',
    () => store.update((state) => state.copy(
        items: [...state.items]..swap(state.index, state.index + 1),
        index: state.index + 1)),
    isEnabled: () => store.state.index < store.state.items.length - 1,
    isMenu: constantFunction0(false),
  ),
  Operation(
    'a',
    'Add',
    () {
      stdout.write('Add: ');
      final item = stdin.readLineSync();
      if (item != null) {
        store.update((state) =>
            state.copy(items: [...state.items]..insert(state.index, item)));
      }
    },
  ),
  Operation(
    'x',
    'Remove',
    () {
      store.update((state) =>
          state.copy(items: [...state.items]..removeAt(state.index)));
    },
    isEnabled: () => store.state.items.isNotEmpty,
  ),
  Operation(
    'u',
    'Undo',
    store.undo,
    isEnabled: () => store.canUndo,
  ),
  Operation(
    'r',
    'Redo',
    store.redo,
    isEnabled: () => store.canRedo,
  ),
  Operation(
    'q',
    'Quit',
    () => exit(0),
  ),
];

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
    stdout.writeln(operations
        .where((operation) => operation.isEnabled() && operation.isMenu())
        .join(''));

    // Read the operation from the input.
    stdin.lineMode = stdin.echoMode = false;
    final command = String.fromCharCode(stdin.readByteSync());
    stdin.lineMode = stdin.echoMode = true;

    // Dispatch to the right operation.
    for (final operation in operations) {
      if (operation.key == command && operation.isEnabled()) {
        operation.action();
        break;
      }
    }
  }
}
