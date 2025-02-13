import 'package:more/functional.dart';

import '../../core.dart';
import 'value.dart';

/// A computed reactive value.
class Computed<T> extends Value<T> {
  Computed(this._callback) {
    _update();
  }

  final Map0<T> _callback;
  late final ComputedObserver<T> _observer = ComputedObserver<T>(this);

  State _state = State.initializing;
  T? _value;
  Object? _error;
  StackTrace? _stackTrace;

  @override
  T get value {
    if (active != null) subscribe(active as Observer<T>);
    switch (_state) {
      case State.initializing:
      case State.computing:
        throw CircularDependencyError();
      case State.computed:
        return _value as T;
      case State.errored:
        throw UnhandledError(_error!, _stackTrace!);
    }
  }

  void _update() {
    final previous = active;
    active = _observer;
    _state = State.computing;
    _value = null;
    _error = null;
    _stackTrace = null;
    try {
      final value = _callback();
      _state = State.computed;
      update(_value = value);
    } catch (error, stackTrace) {
      _state = State.errored;
      _error = error;
      _stackTrace = stackTrace;
    } finally {
      active = previous;
    }
  }
}

enum State { initializing, computing, computed, errored }

class ComputedObserver<T> implements Observer<Never> {
  ComputedObserver(this._computed);

  final Computed<T> _computed;

  @override
  void next(Object? value) => _computed._update();

  @override
  void error(Object error, StackTrace stackTrace) => _computed._update();

  @override
  void complete() => _computed._update();

  @override
  bool get isDisposed => throw UnimplementedError();

  @override
  void dispose() => throw UnimplementedError();
}
