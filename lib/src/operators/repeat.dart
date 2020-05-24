library rx.operators.repeat;

import '../constructors/empty.dart';
import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../shared/constants.dart';

extension RepeatOperator<T> on Observable<T> {
  /// Resubscribes on this observable [count] times.
  Observable<T> repeat([int count = maxInteger]) => count <= 0
      ? empty()
      : count == 1 ? this : RepeatObservable<T>(this, count);
}

class RepeatObservable<T> extends Observable<T> {
  final Observable<T> delegate;
  final int count;

  RepeatObservable(this.delegate, this.count);

  @override
  Disposable subscribe(Observer<T> observer) =>
      RepeatSubscriber<T>(delegate, observer, count);
}

class RepeatSubscriber<T> extends Subscriber<T> {
  final Observable<T> delegate;

  int count;
  Disposable iteration;

  RepeatSubscriber(this.delegate, Observer<T> observer, this.count)
      : super(observer) {
    restart();
  }

  @override
  void onComplete() {
    restart();
  }

  void restart() {
    if (iteration != null) {
      remove(iteration);
    }
    if (count > 0) {
      add(iteration = delegate.subscribe(this));
    } else {
      doComplete();
    }
    count--;
  }
}
