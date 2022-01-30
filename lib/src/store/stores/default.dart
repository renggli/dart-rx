import '../../core/observer.dart';
import '../../disposables/disposable.dart';
import '../../subjects/subject.dart';
import '../store.dart';
import '../types.dart';

/// A canonical redux-like store object with listeners.
class DefaultStore<S> implements Store<S> {
  /// Constructs a default store from the provided state.
  DefaultStore(this._state);

  /// Internal field keeping a reference to the current state.
  S _state;

  /// Internal subject managing the listeners of state changes.
  final Subject<S> _subject = Subject<S>();

  @override
  S get state => _state;

  @override
  S update(Updater<S> updater) {
    _state = updater(_state);
    _subject.next(_state);
    return _state;
  }

  @override
  Disposable subscribe(Observer<S> observer) => _subject.subscribe(observer);
}
