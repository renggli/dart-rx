import '../core/observable.dart';
import '../observables/connectable.dart';
import '../subjects/async_subject.dart';
import '../subjects/behavior_subject.dart';
import '../subjects/replay_subject.dart';
import 'multicast.dart';

extension PublishOperator<T> on Observable<T> {
  /// Creates a [ConnectableObservable] that emits its initial or last seen
  /// value to its subscribers.
  ///
  /// For example:
  ///
  /// ```dart
  /// final observable = just(1).publishBehavior(0);
  /// observable.connect();
  /// observable.subscribe(Observer(next: print)); // prints 0, 1
  /// ```
  ConnectableObservable<T> publishBehavior(T value) =>
      multicast(subject: BehaviorSubject<T>(value));

  /// Creates a [ConnectableObservable] that emits its last value to all its
  /// subscribers on completion.
  ///
  /// For example:
  ///
  /// ```dart
  /// final observable = just(1).publishLast();
  /// observable.connect();
  /// observable.subscribe(Observer(next: print)); // prints 1
  /// ```
  ConnectableObservable<T> publishLast() =>
      multicast(subject: AsyncSubject<T>());

  /// Creates a [ConnectableObservable] that replays all its previous values to
  /// new subscribers.
  ///
  /// For example:
  ///
  /// ```dart
  /// final observable = just(1).publishReplay();
  /// observable.connect();
  /// observable.subscribe(Observer(next: print)); // prints 1
  /// ```
  ConnectableObservable<T> publishReplay({int? bufferSize}) =>
      multicast(subject: ReplaySubject<T>(bufferSize: bufferSize));
}
