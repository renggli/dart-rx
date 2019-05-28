library rx.core.subscription;

import 'dart:async' as async;

typedef TeardownLogic = void Function();

abstract class Subscription {
  factory Subscription.of(Object object) {
    if (object is TeardownLogic) {
      return TeardownSubscription(object);
    }
    return ActiveSubscription();
  }

  bool get isSubscribed;

  void unsubscribe();
}

class InactiveSubscription implements Subscription {
  const InactiveSubscription();

  @override
  bool get isSubscribed => false;

  @override
  void unsubscribe() {}
}

class ActiveSubscription implements Subscription {
  @override
  bool isSubscribed = true;

  @override
  void unsubscribe() => isSubscribed = false;
}

class TeardownSubscription implements Subscription {
  final TeardownLogic teardownLogic;

  TeardownSubscription(this.teardownLogic);

  @override
  bool isSubscribed = true;

  @override
  void unsubscribe() {
    if (isSubscribed) {
      isSubscribed = false;
      teardownLogic();
    }
  }
}

class CompositeSubscription implements Subscription {
  final Set<Subscription> subscriptions = {};

  CompositeSubscription();

  @override
  bool isSubscribed = true;

  void add(Subscription subscription) {
    if (isSubscribed) {
      subscriptions.add(subscription);
    } else {
      subscription.unsubscribe();
    }
  }

  @override
  void unsubscribe() {
    if (isSubscribed) {
      for (final subscription in subscriptions) {
        subscription.unsubscribe();
      }
      subscriptions.clear();
      isSubscribed = false;
    }
  }
}

class TimerSubscription extends ActiveSubscription {
  final async.Timer timer;

  TimerSubscription(this.timer);

  @override
  void unsubscribe() {
    super.unsubscribe();
    timer.cancel();
  }
}

class StreamSubscription extends ActiveSubscription {
  final async.StreamSubscription stream;

  StreamSubscription(this.stream);

  @override
  void unsubscribe() {
    super.unsubscribe();
    stream.cancel();
  }
}
