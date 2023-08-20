import '../../core.dart';
import '../../disposables.dart';

extension PairwiseOperator<T> on Observable<T> {
  /// Groups the items emitted by an Observable into a
  /// [record type](https://dart.dev/language/records) that represent the
  /// latest pair of items emitted by the source Observable.
  ///
  /// For example `[1, 2, 3, 4].toObservable().pairwise()` yields `(1, 2)`,
  /// `(2, 3)`, and `(3, 4)`.
  Observable<(T, T)> pairwise() => PairwiseObservable<T>(this);
}

class PairwiseObservable<T> extends Observable<(T, T)> {
  PairwiseObservable(this.source);

  final Observable<T> source;

  @override
  Disposable subscribe(Observer<(T, T)> observer) {
    final subscriber = PairwiseSubscriber<T>(observer);
    subscriber.add(source.subscribe(subscriber));
    return subscriber;
  }
}

class PairwiseSubscriber<T> extends Subscriber<T> {
  PairwiseSubscriber(Observer<(T, T)> super.observer);

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
