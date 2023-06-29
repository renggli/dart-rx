import '../../core.dart';
import '../../disposables.dart';

extension PairwiseOperator<T> on Observable<T> {
  /// Groups the items emitted by an Observable into [Pair] objects that
  /// represent the latest pair of items emitted by the source Observable.
  ///
  /// ### Example
  ///
  ///    just([1, 2, 3, 4]).pairwise().subscribe(Observer.next(print)); // prints (1, 2), (2, 3), (3, 4)
  Observable<Pair<T>> pairwise() => PairwiseObservable<T>(this);
}

class PairwiseObservable<T> extends Observable<Pair<T>> {
  PairwiseObservable(this.source);

  final Observable<T> source;

  @override
  Disposable subscribe(Observer<Pair<T>> observer) {
    final subscriber = PairwiseSubscriber<T>(observer);
    subscriber.add(source.subscribe(subscriber));
    return subscriber;
  }
}

class PairwiseSubscriber<T> extends Subscriber<T> {
  PairwiseSubscriber(Observer<Pair<T>> super.observer);

  T? previous;

  @override
  void onNext(T value) {
    if (previous != null) {
      doNext(Pair(previous as T, value));
    }
    previous = value;
  }
}

class Pair<T> {
  Pair(this.first, this.second);

  final T first;
  final T second;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pair &&
          runtimeType == other.runtimeType &&
          first == other.first &&
          second == other.second;

  @override
  int get hashCode => first.hashCode ^ second.hashCode;

  @override
  String toString() => '($first, $second)';
}
