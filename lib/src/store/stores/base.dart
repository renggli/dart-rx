import '../../core/observer.dart';
import '../../disposables/disposable.dart';
import '../../subjects/subject.dart';
import '../store.dart';
import '../types.dart';

class BaseStore<S> implements Store<S> {
  BaseStore(this.state);

  final Subject<S> subject = Subject<S>();

  @override
  S state;

  @override
  S update(Updater<S> updater) {
    state = updater(state);
    subject.next(state);
    return state;
  }

  @override
  Disposable subscribe(Observer<S> observer) => subject.subscribe(observer);
}
