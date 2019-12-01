library rx.subjects.replay;

import 'package:collection/collection.dart';

import '../core/observer.dart';
import '../disposables/disposable.dart';
import 'subject.dart';

/// A [Subject] that replays all its previous values to new subscribers.
class ReplaySubject<T> extends Subject<T> {
  final int bufferSize;

  final QueueList<T> _buffer;

  ReplaySubject({this.bufferSize}) : _buffer = QueueList(bufferSize);

  @override
  void next(T value) {
    if (bufferSize != null) {
      while (_buffer.length >= bufferSize) {
        _buffer.removeFirst();
      }
    }
    _buffer.addLast(value);
    super.next(value);
  }

  @override
  Disposable subscribeToActive(Observer observer) {
    _buffer.forEach(observer.next);
    return super.subscribeToActive(observer);
  }

  @override
  Disposable subscribeToComplete(Observer observer) {
    _buffer.forEach(observer.next);
    return super.subscribeToComplete(observer);
  }
}
