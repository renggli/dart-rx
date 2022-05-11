import 'package:more/functional.dart';

import '../core/observable.dart';
import '../core/observer.dart';
import '../core/subscriber.dart';
import '../disposables/disposable.dart';
import '../disposables/disposed.dart';
import '../disposables/sequential.dart';
import '../events/event.dart';
import '../observers/inner.dart';

extension SwitchAllOperator<T> on Observable<Observable<T>> {
  /// Emits values only from the most recently received higher-order
  /// [Observable].
  Observable<T> switchAll() => switchMap<T>(identityFunction);
}

extension SwitchMapOperator<T> on Observable<T> {
  /// Emits all values from the most recent higher-order `observable`.
  Observable<R> switchMapTo<R>(Observable<R> observable) =>
      switchMap<R>(constantFunction1(observable));

  /// Emits values from the most recent higher-order [Observable] retrieved by
  /// projecting the values of the source to higher-order [Observable]s.
  Observable<R> switchMap<R>(Map1<T, Observable<R>> project) =>
      SwitchObservable<T, R>(this, project);
}

class SwitchObservable<T, R> implements Observable<R> {
  SwitchObservable(this.delegate, this.project);

  final Observable<T> delegate;
  final Map1<T, Observable<R>> project;

  @override
  Disposable subscribe(Observer<R> observer) {
    final subscriber = SwitchSubscriber<T, R>(observer, project);
    subscriber.add(delegate.subscribe(subscriber));
    return subscriber;
  }
}

class SwitchSubscriber<T, R> extends Subscriber<T>
    implements InnerEvents<R, void> {
  SwitchSubscriber(Observer<R> super.observer, this.project) {
    add(subscription);
  }

  final Map1<T, Observable<R>> project;
  final SequentialDisposable subscription = SequentialDisposable();

  bool hasCompleted = false;

  @override
  void onNext(T value) {
    final projectEvent = Event.map1(project, value);
    if (projectEvent.isError) {
      doError(projectEvent.error, projectEvent.stackTrace);
    } else {
      subscription.current = InnerObserver(this, projectEvent.value, null);
    }
  }

  @override
  void onComplete() {
    hasCompleted = true;
    if (subscription.current.isDisposed) {
      doComplete();
    }
  }

  @override
  void notifyNext(Disposable disposable, void state, R value) => doNext(value);

  @override
  void notifyError(Disposable disposable, void state, Object error,
          StackTrace stackTrace) =>
      doError(error, stackTrace);

  @override
  void notifyComplete(Disposable disposable, void state) {
    subscription.current = const DisposedDisposable();
    if (hasCompleted) {
      doComplete();
    }
  }
}
