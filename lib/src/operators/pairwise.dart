import '../../core.dart';
import '../../disposables.dart';

typedef Pair<T> = (T first, T second);

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

  late T _previous;
  bool _hasPrevious = false;

  @override
  void onNext(T value) {
    if (_hasPrevious) {
      doNext((_previous, value));
    }
    _previous = value;
    _hasPrevious = true;
  }
}
