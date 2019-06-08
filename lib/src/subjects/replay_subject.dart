library rx.subjects.replay;

import 'package:collection/collection.dart';
import 'package:rx/src/core/observer.dart';
import 'package:rx/src/core/subject.dart';
import 'package:rx/src/core/subscription.dart';

/// A variant of Subject that "replays" or emits old values to new subscribers.
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
  Subscription subscribe(Observer<T> observer) {
    final subscription = super.subscribe(observer);
    if (!subscription.isClosed) {
      _buffer.forEach(observer.next);
    }
    return subscription;
  }
}
