import 'package:collection/collection.dart';

import '../core/observer.dart';
import '../disposables/disposable.dart';
import 'subject.dart';

/// A [Subject] that replays all its previous values to new subscribers.
///
/// For example:
///
/// ```dart
/// final subject = ReplaySubject<int>();
/// subject.next(1);
/// subject.next(2);
/// subject.subscribe(Observer(next: print)); // prints 1, 2
/// ```
class ReplaySubject<T> extends Subject<T> {
  ReplaySubject({this.bufferSize}) : _buffer = QueueList(bufferSize);

  final int? bufferSize;
  final QueueList<T> _buffer;

  @override
  void next(T value) {
    if (bufferSize != null) {
      while (_buffer.length >= bufferSize!) {
        _buffer.removeFirst();
      }
    }
    _buffer.addLast(value);
    super.next(value);
  }

  @override
  Disposable subscribeToActive(Observer<T> observer) {
    _buffer.forEach(observer.next);
    return super.subscribeToActive(observer);
  }

  @override
  Disposable subscribeToComplete(Observer<T> observer) {
    _buffer.forEach(observer.next);
    return super.subscribeToComplete(observer);
  }
}
