library rx.core.subscriber;

import 'package:meta/meta.dart';
import 'package:rx/core.dart';

import 'subscription.dart';

class Subscriber<T> implements Observer<T>, Subscription {
  final Observer destination;
  final List<Subscription> subscriptions = [];

  Subscriber(this.destination);

  @override
  void next(T value) {
    if (isSubscribed) {
      onNext(value);
    }
  }

  @protected
  void onNext(T value) => destination.next(value);

  @override
  void error(Object error, [StackTrace stackTrace]) {
    if (isSubscribed) {
      onError(error, stackTrace);
      unsubscribe();
    }
  }

  @protected
  void onError(Object error, [StackTrace stackTrace]) =>
      destination.error(error, stackTrace);

  @override
  void complete() {
    if (isSubscribed) {
      onComplete();
      unsubscribe();
    }
  }

  @protected
  void onComplete() => destination.complete();

  @override
  bool isSubscribed = true;

  @override
  void unsubscribe() {
    if (isSubscribed) {
      isSubscribed = false;
      for (final subscription in subscriptions) {
        subscription.unsubscribe();
      }
    }
  }

  void add(Subscription subscription) {
    if (isSubscribed) {
      subscriptions.add(subscription);
    } else {
      subscription.unsubscribe();
    }
  }
}

class InnerSubscriber<T, R> extends Subscriber<R> {
  final OuterSubscriber<T, R> parent;
  final T outerValue;
  final int outerIndex;
  int index = 0;

  InnerSubscriber(this.parent, this.outerValue, this.outerIndex) : super(null);

  @override
  void onNext(R value) {
    parent.notifyNext(outerValue, value, outerIndex, index++, this);
  }

  @override
  void onError(Object error, [StackTrace stackTrace]) {
    parent.notifyError(error, stackTrace, this);
    unsubscribe();
  }

  @override
  void onComplete() {
    parent.notifyComplete(this);
    unsubscribe();
  }
}

class OuterSubscriber<T, R> extends Subscriber<T> {
  OuterSubscriber(Observer<R> destination) : super(destination);

  void notifyNext(T outerValue, R innerValue, intouterIndex, int innerIndex,
          InnerSubscriber<T, R> innerSubscriber) =>
      destination.next(innerValue);

  void notifyError(Object error, StackTrace stackTrace,
          InnerSubscriber<T, R> innerSubscriber) =>
      destination.error(error, stackTrace);

  void notifyComplete(InnerSubscriber<T, R> innerSubscriber) =>
      destination.complete();
}
