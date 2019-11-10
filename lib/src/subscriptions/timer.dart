library rx.subscriptions.timer;

import 'dart:async' as async;

import '../core/subscription.dart';

class TimerSubscription extends Subscription {
  async.Timer _timer;

  TimerSubscription(this._timer);

  @override
  bool get isClosed => _timer == null;

  @override
  void unsubscribe() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }
}
