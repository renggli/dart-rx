library rx.constructors.concat;

import 'package:rx/src/core/observable.dart';

/// Subscribe to the list of [Observable] in order, and when the previous one
/// complete then subscribe to the next one.
Observable<T> concat<T>(Iterable<Observable<T>> observables) => null;
//
//    _ConcatObservable<T>(observables);
//
//class _ConcatObservable<T> with Observable<T> {
//  final Iterable<Observable<T>> observables;
//
//  const _ConcatObservable(this.observables);
//
//  @override
//  Subscription subscribe(Observer<T> destination) =>
//      _ConcatSubscriber(destination, observables.iterator);
//}
//
//class _ConcatSubscriber<T> extends Subscriber<T> {
//  final Iterator<Observable<T>> observables;
//  Subscription innerSubscription = Subscription();
//
//  _ConcatSubscriber(Observer<T> destination, this.observables)
//      : super(destination);
//
//  void moveNext() {
//    innerSubscription.unsubscribe();
//    if (observables.moveNext()) {
//      innerSubscription = observables.current.subscribe(this);
//    }
//  }
//
//  @override
//  void onError(Object error, [StackTrace stackTrace]) {
//    super.onError(error, stackTrace);
//    moveNext();
//  }
//
//  @override
//  void onComplete() {
//    innerSubscription.unsubscribe();
//    if (observables.moveNext()) {
//      innerSubscription = observables.current.subscribe(this);
//    } else {
//      super.onComplete();
//    }
//  }
//}
