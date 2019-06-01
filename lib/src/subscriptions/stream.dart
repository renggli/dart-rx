library rx.subscriptions.stream;

import 'dart:async' as async;

import 'package:rx/src/core/subscription.dart';

class StreamSubscription extends Subscription {
  async.StreamSubscription _subscription;

  StreamSubscription(this._subscription);

  @override
  bool get isClosed => _subscription == null;

  @override
  void unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}
